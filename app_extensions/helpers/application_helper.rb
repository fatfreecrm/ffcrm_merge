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
      "document.observe('dom:loaded', function() { #{js} });"
    end
  end

end

