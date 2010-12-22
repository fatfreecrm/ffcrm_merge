class MergeViewHooks < FatFreeCRM::Callback::Base
 
  def contact_tools_before(view, context = {})   
    view.render(:partial => "/contacts/merge_contact_tool", :locals => {:contact => context[:contact]})
  end
  
  def account_tools_before(view, context = {})   
    view.render(:partial => "/accounts/merge_account_tool", :locals => {:account => context[:account]})
  end

  def javascript_epilogue(view, context = {})
    # Load the crm_merge.js file in the same directory.
    File.open(File.join(File.dirname(__FILE__),'..','..','public','javascripts','crm_merge.js'), 'r').read
  end

end
