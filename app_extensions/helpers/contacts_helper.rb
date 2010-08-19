ContactsHelper.module_eval do

  # Transforms the list of merge attributes into a display
  # format (ie, with links / model associations), to be
  # displayed in the merge selection table.
  # --------------------------------------------------------
  def pretty_merge_attributes(contact, html = true)
    attr_hash = contact.merge_attributes
    # ------ Humanize attributes
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
    # ------ Boolean values should be yes/no
    attr_hash['do_not_call'] = attr_hash['do_not_call'] == true ? "Yes" : "No"
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

  def link_to_new_window(text, path)
    link_to(text, path, :target => "_blank")
  end

  def ordered_merge_attributes
    %w(
      first_name
      last_name
      email
      alt_email
      phone
      mobile
      fax
      do_not_call
      born_on
      title
      background_info
      source
      department
      facebook
      twitter
      blog
      linkedin
      user_id
      assigned_to
      reports_to
      lead_id
      access
      )
  end

  # Returns a hash with default merge attributes for radio buttons.
  # (master contact is default)
  # --------------------------------------------------------
  def calculate_default_merge(contact_attr, master_attr)
    merge = {}
    contact_attr.each do |attribute, dup_value|
      master_value = master_attr[attribute]
      if not master_value.blank?
        merge[attribute] = :master
      elsif not dup_value.blank?
        merge[attribute] = :duplicate
      end
    end
    merge
  end

  # Generates a radio button for selecting which attributes
  # to ignore from the duplicate contact.
  # --------------------------------------------------------
  def ignore_merge_radio_button(value, attribute, merge_case)
    case merge_case
    when :master
      checked = value == "yes" ? {:checked => "checked"} : {}
    when :duplicate
      checked = value == "no"  ? {:checked => "checked"} : {}
    end
    tag("input", {:type  => "radio",
                  :name  => "ignore[#{attribute}]",
                  :id    => "ignore_#{attribute}_#{value}",
                  :value => value
                  }.merge(checked))
  end

end

