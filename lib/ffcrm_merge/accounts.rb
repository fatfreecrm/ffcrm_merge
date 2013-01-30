module Merge
  module Accounts

    IGNORED_ATTRIBUTES = %w(updated_at created_at deleted_at id)
  
    # Call this method on the duplicate account, to merge it
    # into the master account.
    # All attributes from 'self' are default, unless defined in options.
    def merge_with(master_account, ignored_attr = [])
      # Just in case a user tries to merge a account with itself,
      # even though the interface prevents this from happening.
      return false if master_account == self

      # Perform all actions in an atomic transaction, so that if one part of the process fails, the
      # whole merge can be rolled back.
      Account.transaction do

        # ------ Remove ignored attributes from this account
        merge_attr = self.merge_attributes
        ignored_attr.each { |attr| merge_attr.delete(attr) }

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
        
        # Merge tags
        all_tags = (self.tags + master_account.tags).uniq
        master_account.tag_list = all_tags.map(&:name).join(", ")

        # Account validates the uniqueness of name, so we need to alter the duplicate name
        # before we save the master, then destroy the duplicate.
        tmp_name = self.name
        self.update_attribute :name, "#{tmp_name} is being merged - #{self.created_at.to_s}"
        
        master_account.merge_hook(self)

        if master_account.save!
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
          end
        else
          # Restore the duplicate name if something goes wrong.
          # TODO should be covered in transaction
          # self.update_attribute :name, tmp_name
          # false
        end
      end # transaction
    end

    # Defines the list of Contact class attributes we want to merge.
    def merge_attributes
      self.attributes.dup.reject{ |k,v| ignored_merge_attributes.include?(k) }
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

Account.class_eval do
  include Merge::Accounts
end

# TODO lazy loading would be better here
# something like (note we haven't defined on_load for account class yet)
# ActiveSupport.on_load :account do
#  include Merge::Accounts
# end
