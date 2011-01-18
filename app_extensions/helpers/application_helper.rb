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

end

