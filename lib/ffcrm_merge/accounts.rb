module FfcrmMerge
  module Accounts

    IGNORED_ATTRIBUTES = %w(updated_at created_at deleted_at id)
    ORDERED_ATTRIBUTES = %w(name email website phone toll_free_phone
      fax background_info user_id assigned_to access)
  
    # Call this method on the duplicate account, to merge it
    # into the master account.
    # All attributes from 'self' are default, unless defined in options.
    def merge_with(master, ignored_attr = [])
      # Just in case a user tries to merge a account with itself,
      # even though the interface prevents this from happening.
      return false if master == self

      merge_attr = self.merge_attributes
      # ------ Remove ignored attributes from this account
      ignored_attr.each { |attr| merge_attr.delete(attr) }

      # Perform all actions in an atomic transaction, so that if one part of the process fails,
      # the whole merge can be rolled back.
      Account.transaction do

        # ------ Merge attributes: ensure only model attributes are updated.
        model_attributes = merge_attr.dup.reject{ |k,v| !master.attributes.keys.include?(k) }
        master.update_attributes(model_attributes)

        # ------ Merge 'belongs_to' and 'has_one' associations
        {'user_id' => 'user', 'assigned_to' => 'assignee' }.each do |attr, method|
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

        # ------ Merge contacts
        self.contacts.each do |contact|
          # Check if contact belongs to master already? Can happen in CRM's where contacts can belong to multiple accounts
          if AccountContact.where(:contact_id => contact.id).where(:account_id => master.id).size == 0
            ac = AccountContact.where(:contact_id => contact.id).where(:account_id => self.id).first
            ac.account_id = master.id
            ac.save!
          end
        end

        # ------ Merge 'has_many' associations
        self.tasks.each { |t| t.asset = master; t.save! }
        self.emails.each { |e| e.mediator = master; e.save! }
        self.comments.each { |c| c.commentable = master; c.save! }
        self.opportunities.each { |o| o.account = master; o.save! }
        
        # Merge tags
        all_tags = (self.tags + master.tags).uniq
        master.tag_list = all_tags.map(&:name).join(", ")

        # Account validates the uniqueness of name, so we need to alter the duplicate name
        # before we save the master, then destroy the duplicate.
        tmp_name = self.name
        self.update_attribute :name, "#{tmp_name} is being merged - #{self.created_at.to_s}"
        
        # Call the merge_hook - useful if you have custom actions that need to happen during a merge
        master.merge_hook(self)

        if master.save!
          # Update any existing aliases that were pointing to the duplicate record
          AccountAlias.find_all_by_account_id(self.id).each do |aa|
            aa.update_attribute(:account, master)
          end

          # Create the account alias and destroy the merged account.
          if AccountAlias.create(:account => master,
                                 :destroyed_account_id => self.id)
            # Must force a reload of the account, and shake off all migrated assets.
            self.reload
            self.destroy
          end
        else
          # Restore the duplicate name if something goes wrong.
          # TODO should be covered in transaction
          # self.update_attribute :name, tmp_name
          # false
        end
      end # transaction
    end

    # Defines the list of Account class attributes we want to merge.
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
      {'billing_address'  => self.billing_address.try(:id),
       'shipping_address' => self.shipping_address.try(:id) }
    end
    
    # Returns a list of attributes in the order they should appear on the merge form
    def ordered_merge_attributes
      ORDERED_ATTRIBUTES
    end

    # returns a list of attributes that should be ignored in the merge
    # a function so it can be easily overriden
    def ignored_merge_attributes
      IGNORED_ATTRIBUTES
    end
    
    #
    # Override this if you want to add additional behavior to merge
    # It is called by master after merge is performed but before it is saved.
    # Make any changes to self if you want things to persist.
    #
    def merge_hook(duplicate)
      # Example code:
      # duplicate.custom_association.each do |ca|
        # ca.account = self; ca.save!
      # end
    end

  end
end
