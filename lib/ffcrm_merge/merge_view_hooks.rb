class MergeViewHooks < FatFreeCRM::Callback::Base
  
  def contact_tools_before(view, context = {})   
    view.render(:partial => 'contacts/merge_tool', :locals => {:contact => context[:contact]})
  end
  
  def account_tools_before(view, context = {})   
    view.render(:partial => 'accounts/merge_tool', :locals => {:account => context[:account]})
  end
end
