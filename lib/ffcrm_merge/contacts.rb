module Merge
  module Contacts
    # Call this method on the duplicate contact, to merge it
    # into the master contact.
    # All attributes from 'self' are default, unless defined in options.
    def merge_with(master, ignored_attr = {})
      # Just in case a user tries to merge a contact with itself,
      # even though the interface prevents this from happening.
      return false if master == self

      # Perform all actions in an atomic transaction, so that if one part of the process fails, the
      # whole merge can be rolled back.
      Contact.transaction do
        # ------ Remove ignored attributes from this contact
        merge_attr = self.merge_attributes
        (ignored_attr["_self"] || []).each do |attr|
          merge_attr.delete(attr)
        end
        # ------ Merge class attributes
        master.update_attributes(merge_attr)
        # ------ Merge 'belongs_to' and 'has_one' associations
        %w(user lead assignee business_address).each do |attr|
          unless ignored_attr.include?(attr)
            master.send(attr + "=", self.send(attr))
          end
        end
        # ------ Merge 'has_many' associations (each requires a special case)
        self.tasks.each do |t|
          t.asset = master; t.save!
        end
        self.emails.each do |e|
          e.mediator = master; e.save!
        end
        self.comments.each do |c|
          c.commentable = master; c.save!
        end

        # Find all AccountContact records with the duplicate contact,
        # and only add the master contact if it is not already added to the account.
        AccountContact.find_all_by_contact_id(self.id).each do |ac|
          unless ac.account.contacts.include?(master)
            ac.contact_id = master.id; ac.save!
          end
        end
        
        # Find all ContactOpportunity records with the duplicate contact,
        # and only add the master contact if it is not already added to the opportunity.
        ContactOpportunity.find_all_by_contact_id(self.id).each do |co|
          unless co.opportunity.contacts.include?(master)
            co.contact_id = master.id; co.save!
          end
        end

        # Merge tags
        all_tags = (self.tags + master.tags).uniq
        master.tag_list = all_tags.map(&:name).join(", ")

        if master.save!
          # Update any existing aliases that were pointing to the duplicate record
          ContactAlias.find_all_by_contact_id(self.id).each do |ca|
            ca.update_attribute(:contact, master)
          end

          # Create the contact alias and destroy the merged contact.
          if ContactAlias.create(:contact => master,
                                 :destroyed_contact_id => self.id)
            # Must force a reload of the contact, and shake off all migrated assets.
            self.reload
            self.destroy
          end
        end
      end
    end

    # Defines the list of Contact class attributes we want to merge.
    def merge_attributes
      %w(updated_at
         created_at
         deleted_at
         id).inject(self.attributes) do |r, n|
          r.delete(n)
          r
      end
    end

  end
end
