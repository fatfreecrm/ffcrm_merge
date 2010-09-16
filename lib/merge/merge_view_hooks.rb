class MergeViewHooks < FatFreeCRM::Callback::Base

  def javascript_includes(view, context = {})
    view.javascript_include_tag('crm_merge_contacts.js')
  end
  
  def contact_tools_before(view, context = {})   
    view.render(:partial => "/contacts/merge_contact_tool", :locals => {:contact => context[:contact]})
  end

end

