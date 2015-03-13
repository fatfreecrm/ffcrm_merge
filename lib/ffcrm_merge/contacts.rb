module FfcrmMerge
  module Contacts

    IGNORED_ATTRIBUTES = %w(updated_at created_at deleted_at id)
    ORDERED_ATTRIBUTES = %w(first_name last_name email alt_email
      phone mobile fax do_not_call born_on
      title background_info source department
      facebook twitter blog linkedin user_id
      assigned_to reports_to lead_id access business_address)

    # Call this method on the duplicate contact, to merge it
    # into the master contact.
    # All attributes from 'self' are default, unless defined in options.
    def merge_with(master, ignored_attr = [])
      # Just in case a user tries to merge a contact with itself,
      # even though the interface prevents this from happening.
      return false if master == self

      merge_attr = self.merge_attributes
      # ------ Remove ignored attributes from this contact
      ignored_attr.each { |attr| merge_attr.delete(attr) }

      # Perform all actions in an atomic transaction, so that if one part of the process fails,
      # the whole merge can be rolled back.
      Contact.transaction do

        # ------ Merge attributes: ensure only model attributes are updated.
        model_attributes = merge_attr.dup.reject{ |k,v| !master.attributes.keys.include?(k) }
        master.update_attributes(model_attributes)

        # ------ Merge 'belongs_to' and 'has_one' associations
        {'user_id' => 'user', 'lead_id' => 'lead', 'assigned_to' => 'assignee'}.each do |attr, method|
          unless ignored_attr.include?(attr)
            master.send(method + "=", self.send(method))
          end
        end

        # ------ Merge address associations
        master.address_attributes.keys.each do |attr|
          unless ignored_attr.include?(attr)
            master.send(attr + "=", self.send(attr))
          end
        end

        # ------ Merge 'has_many' associations
        self.tasks.each { |t| t.asset = master; t.save! }
        self.emails.each { |e| e.mediator = master; e.save! }
        self.comments.each { |c| c.commentable = master; c.save! }

        # Find all AccountContact records with the duplicate contact,
        # and only add the master contact if it is not already added to the account.
        AccountContact.where(contact_id: self.id).each do |ac|
          unless ac.account.contacts.include?(master)
            ac.contact_id = master.id; ac.save!
          end
        end

        # Find all ContactOpportunity records with the duplicate contact,
        # and only add the master contact if it is not already added to the opportunity.
        ContactOpportunity.where(contact_id: self.id).each do |co|
          unless co.opportunity.contacts.include?(master)
            co.contact_id = master.id; co.save!
          end
        end

        # Merge tags
        all_tags = (self.tags + master.tags).uniq
        master.tag_list = all_tags.map(&:name).join(", ")

        # Call the merge_hook - useful if you have custom actions that need to happen during a merge
        master.merge_hook(self)

        if master.save!
          # Update any existing aliases that were pointing to the duplicate record
          ContactAlias.where(contact_id: self.id).each do |ca|
            ca.update_attribute(:contact, master)
          end

          # Create the contact alias and destroy the merged contact.
          if ContactAlias.create(:contact => master,
                                 :destroyed_contact_id => self.id)
            # Must force a reload of the contact, and shake off all migrated assets.
            self.reload
            self.destroy
          end
          true
        else
          false
        end
      end # transaction
    end

    # Defines the list of Contact class attributes we want to merge.
    # in the order we want to specify them
    def merge_attributes
      attrs = self.attributes.dup.reject{ |k,v| ignored_merge_attributes.include?(k) }
      attrs.merge!(address_attributes) # we want addresses to be shown in the UI
      sorted = attrs.sort do |a,b|
        (ordered_merge_attributes.index(a.first) || 1000) <=> (ordered_merge_attributes.index(b.first) || 1000)
      end
      sorted.inject({}) do |h, item|
        h[item.first] = item.second
        h
      end
    end

    # These attributes need to be included on the merge form but ignore in update_attributes
    # and merged later on in the merge script
    def address_attributes
      {'business_address' => self.business_address.try(:id) }
    end

    # Returns a list of attributes in the order they should appear on the merge form
    def ordered_merge_attributes
      ORDERED_ATTRIBUTES
    end

    # Returns a list of attributes that should be ignored in the merge
    # a function so it can be easily overriden
    def ignored_merge_attributes
      IGNORED_ATTRIBUTES
    end

    #
    # Override this if you want to add additional behavior to merge
    # It is called after merge is performed but before it is saved.
    #
    def merge_hook(duplicate)
      # Example code:
      # duplicate.custom_association.each do |ca|
        # ca.contact = self; ca.save!
      # end
    end

  end
end
