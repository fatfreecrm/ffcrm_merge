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

  # Had to define this method to allow select popup to be also
  # used for merging records. (Could not append optional param
  # to load_select_popups_for because of *assets)
  # Also needed to make all popup ids unique for each contact,
  # so this method must be singularized.
  #----------------------------------------------------------------------------
  def load_merge_select_popup_for(asset)
    js = render(:partial => "common/merge_select_popup",
                :locals  => { :asset => asset })

    content_for(:javascript_epilogue) do
      raw "document.observe('dom:loaded', function() { #{js} });"
    end
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

