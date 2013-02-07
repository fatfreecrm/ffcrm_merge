module ContactsMergeHelper

  # Transforms the list of merge attributes into a display
  # format (ie, with links / model associations), to be
  # displayed in the merge selection table.
  # --------------------------------------------------------
  def contact_merge_attributes(contact, html = true)
    attr_hash = contact.merge_attributes

    # ------ Humanize attributes

    merge_boolean_attributes!(attr_hash)
    merge_subscribed_users_attributes!(attr_hash)
    merge_address_attributes!(attr_hash, contact)
    
    attr_hash['source'] = attr_hash['source'].humanize if attr_hash['source']
    # ------ Make websites into links and emails into mailto links
    if html
      %w(blog linkedin facebook twitter).each do |attribute|
        if link = attr_hash[attribute] and not link.blank?
          attr_hash[attribute] = link_to_new_window(link, link)
        end
      end
      %w(email alt_email).each do |attribute|
        if email = attr_hash[attribute] and not email.blank?
          attr_hash[attribute] = mail_to(email)
        end
      end
    end

    # ------ User relationships should display user's full name
    %w(assigned_to reports_to user_id).each do |attribute|
      if attr_hash[attribute]
        user = User.find(attr_hash[attribute])
        attr_hash[attribute] = html ? link_to_new_window(user.full_name, user_path(user)) : user.full_name
      end
    end

    # ------ Lead relationship should display lead's full name
    if attr_hash['lead_id']
      lead = Lead.find(attr_hash['lead_id'])
      attr_hash['lead_id'] = html ? link_to_new_window(lead.full_name, lead_path(lead)) : lead.full_name
    end

    attr_hash
  end
  
end
