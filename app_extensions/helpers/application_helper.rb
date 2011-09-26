ApplicationHelper.module_eval do

  # Adds 'edit_action => merge' to 'link_to_edit' generator.
  def link_to_merge(contact)
    link_to_remote(t(:merge),
      :method => :get,
      :url    => send("edit_contact_path", contact),
      :with   => %Q"{ previous: crm.find_form('edit_contact'),
                      edit_action: 'merge' }"
    )
  end

  # ---------------- Common Merge Helper Methods ---------------------

  # Generates a radio button for selecting which attributes
  # to ignore from the duplicate contact.
  # --------------------------------------------------------
  def ignore_merge_radio_button(value, attribute, merge_case, tag = nil)
    case merge_case
    when :master
      checked = value == "yes" ? {:checked => "checked"} : {}
    when :duplicate
      checked = value == "no"  ? {:checked => "checked"} : {}
    end
    tag_name = tag.blank? ? "ignore[_self][#{attribute}]" : "ignore[tags][#{tag.downcase}][#{attribute}]"
    tag_id = tag.blank? ? "ignore_self_#{attribute}_#{value}" : "ignore_tags_#{tag.downcase}_#{attribute}_#{value}"

    tag("input", {:type  => "radio",
                  :name  => tag_name,
                  :id    => tag_id,
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
  def custom_field_merge_attributes(tag, asset, html = true)
    association = "tag#{tag.id}"
    object = asset.send(association)
    customfields = tag.customfields.sort{|a,b| (a.position || 0) <=> (b.position || 0) }
    customfields.inject({}){|hash,custom| hash[custom.field_name] = custom.display_value(object); hash }
  end

end

