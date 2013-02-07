module MergeHelper

  def link_to_new_window(text, path)
    link_to(h(text), path, :target => "_blank")
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

    tag(:input, {
      :type  => "radio",
      :name  => "ignore[_self][#{attribute}]",
      :id    => "ignore_self_#{attribute}_#{value}",
      :value => value
    }.merge(checked))
  end

  # Returns a hash with default merge attributes for radio buttons.
  # (master contact is default)
  # --------------------------------------------------------
  def calculate_default_merge(duplicate_attr, master_attr)
    merge = {}
    duplicate_attr.each do |attribute, dup_value|
      master_value = master_attr[attribute]
      if not master_value.blank?
        merge[attribute] = :master
      elsif not dup_value.blank?
        merge[attribute] = :duplicate
      end
    end
    merge
  end


  # Merge attributes for custom fields
  # --------------------------------------------------------
  # Transforms the list of merge attributes into a display
  # format (ie, with links / model associations), to be
  # displayed in the merge selection table.
  # --------------------------------------------------------
  def custom_field_merge_attributes(field_group, object)
    custom_fields = field_group.fields.sort_by(&:position)
    custom_fields.inject({}){ |hash, field| hash[field.name] = field.render_value(object); hash }
  end
  
  # Transforms any boolean attributes into a display format 
  # --------------------------------------------------------
  def merge_boolean_attributes!(attributes)
    attributes.each do |key, value|
      if value.is_a?(TrueClass) or value.is_a?(FalseClass)
        attributes[key] = (attributes[key] == true) ? "Yes" : "No"
      end
    end
  end
  
  # Transforms subscribed users into a display format
  # --------------------------------------------------------
  def merge_subscribed_users_attributes!(attr_hash)
    if attr_hash.keys.include?('subscribed_users')
      attr_hash['subscribed_users'] = attr_hash['subscribed_users'].to_a.compact.map do |value|
        user = User.find(value)
        link_to_new_window(user.full_name, user_path(user))
      end.join(', ').html_safe
    end
  end

  # Transforms any address attributes into a display format
  # --------------------------------------------------------
  def merge_address_attributes!(attributes, entity)
    attributes.each do |key, value|
      if key =~ /_address/ and attributes[key]
        address_type = key.gsub('_address', '')
        attributes[key] = render("shared/address_show", :asset => entity, :type => address_type)
      end
    end
  end

end
