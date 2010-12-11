module Merge
  module Contacts
    # Call this method on the duplicate contact, to merge it
    # into the master contact.
    # All attributes from 'self' are default, unless defined in options.
    def merge_with(master_contact, ignored_attr = [])
      # Just in case a user tries to merge a contact with itself,
      # even though the interface prevents this from happening.
      return false if master_contact == self

      # ------ Remove ignored attributes from this contact
      merge_attr = self.merge_attributes
      ignored_attr.each do |attr|
        merge_attr.delete(attr)
      end
      # ------ Merge class attributes
      master_contact.update_attributes(merge_attr)
      # ------ Merge 'belongs_to' and 'has_one' associations
      %w(user lead assignee account business_address).each do |attr|
        unless ignored_attr.include?(attr)
          master_contact.send(attr + "=", self.send(attr))
        end
      end
      # ------ Merge 'has_many' associations (each requires a special case)
      self.tasks.each do |t|
        t.asset = master_contact; t.save!
      end
      self.emails.each do |e|
        e.mediator = master_contact; e.save!
      end
      self.comments.each do |c|
        c.commentable = master_contact; c.save!
      end
      # Find all ContactOpportunity records with the duplicate contact,
      # and only add the master contact if it is not already added to the opportunity.
      ContactOpportunity.find_all_by_contact_id(self.id).each do |co|
        unless co.opportunity.contacts.include?(master_contact)
          co.contact_id = master_contact.id; co.save!
        end
      end

      if master_contact.save!
        # Update any existing aliases that were pointing to the duplicate record
        ContactAlias.find_all_by_contact_id(self.id).each do |ca|
          ca.update_attribute(:contact, master_contact)
        end
        
        # Create the contact alias and destroy the merged contact.
        if ContactAlias.create(:contact => master_contact,
                               :destroyed_contact_id => self.id)
          # Must force a reload of the contact, and shake off all migrated assets.
          self.reload
          self.destroy!
          return true
        end
      end
      false
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

