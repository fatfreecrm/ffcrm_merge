module Merge
  module Accounts
    # Call this method on the duplicate account, to merge it
    # into the master account.
    # All attributes from 'self' are default, unless defined in options.
    def merge_with(master_account, ignored_attr = {})
      # Just in case a user tries to merge a account with itself,
      # even though the interface prevents this from happening.
      return false if master_account == self

      # ------ Remove ignored attributes from this account
      merge_attr = self.merge_attributes
      (ignored_attr || []).each do |attr|
        merge_attr.delete(attr)
      end
      # ------ Merge class attributes
      master_account.update_attributes(merge_attr)
      # ------ Merge 'belongs_to' and 'has_one' associations
      %w(user assignee billing_address shipping_address).each do |attr|
        unless ignored_attr.include?(attr)
          master_account.send(attr + "=", self.send(attr))
        end
      end
      # ------ Merge 'has_many' associations (each requires a special case)
      self.contacts.each do |t|
        t.account = master_account; t.save!
      end
      self.tasks.each do |t|
        t.asset = master_account; t.save!
      end
      self.emails.each do |e|
        e.mediator = master_account; e.save!
      end
      self.comments.each do |c|
        c.commentable = master_account; c.save!
      end

      self.opportunities.each do |o|
        o.account = master_account; o.save!
      end

      # Account validates the uniqueness of name, so we need to alter the duplicate name
      # before we save the master, then destroy the duplicate.
      tmp_name = self.name
      self.update_attribute :name, "Soon to be destroyed - #{self.created_at.to_s}"

      if master_account.save
        # Update any existing aliases that were pointing to the duplicate record
        AccountAlias.find_all_by_account_id(self.id).each do |aa|
          aa.update_attribute(:account, master_account)
        end

        # Create the account alias and destroy the merged account.
        if AccountAlias.create(:account => master_account,
                               :destroyed_account_id => self.id)
          # Must force a reload of the account, and shake off all migrated assets.
          self.reload
          self.destroy
          return true
        end
      else
        # Restore the duplicate name if something goes wrong.
        self.update_attribute :name, tmp_name
      end
      false
    end

    # Defines the list of Account class attributes we want to merge.
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

Account.class_eval do
  include Merge::Accounts
end
