class MergeViewHooks < FatFreeCRM::Callback::Base

  def javascript_includes(view, context = {})
    view.javascript_include_tag('crm_merge.js')
  end
  
  def contact_tools_before(view, context = {})   
    view.render(:partial => "/contacts/merge_contact_tool", :locals => {:contact => context[:contact]})
  end
  
  def account_tools_before(view, context = {})   
    view.render(:partial => "/accounts/merge_account_tool", :locals => {:account => context[:account]})
  end

end

