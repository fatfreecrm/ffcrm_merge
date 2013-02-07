module AccountsMergeHelper

  # Transforms the list of merge attributes into a display
  # format (ie, with links / model associations), to be
  # displayed in the merge selection table.
  # --------------------------------------------------------
  def account_merge_attributes(account, html = true)
    attr_hash = account.merge_attributes

    # ------ Humanize attributes
    
    merge_boolean_attributes!(attr_hash)
    merge_subscribed_users_attributes!(attr_hash)
    merge_address_attributes!(attr_hash, account)

    attr_hash['source'] = attr_hash['source'].humanize if attr_hash['source']
    # ------ Make websites into links and emails into mailto links
    if html
      %w(email website).each do |attribute|
        if email = attr_hash[attribute] and not email.blank?
          attr_hash[attribute] = mail_to(email)
        end
      end
    end
    
    # ------ User relationships should display user's full name
    %w(assigned_to user_id).each do |attribute|
      if attr_hash[attribute]
        user = User.find(attr_hash[attribute])
        attr_hash[attribute] = html ? link_to_new_window(user.full_name, user_path(user)) : user.full_name
      end
    end

    attr_hash
  end

end
