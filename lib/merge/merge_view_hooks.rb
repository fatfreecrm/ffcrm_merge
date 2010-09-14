class MergeViewHooks < FatFreeCRM::Callback::Base

  def javascript_includes(view, context = {})
    view.javascript_include_tag('crm_merge_contacts.js')
  end

end

