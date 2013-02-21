module FfcrmMerge

  class MergeViewHooks < FatFreeCRM::Callback::Base
    
    def contact_tools_before(view, context = {})   
      view.render(:partial => 'merge/merge_tool', :locals => {:entity => context[:contact]})
    end
    
    def account_tools_before(view, context = {})   
      view.render(:partial => 'merge/merge_tool', :locals => {:entity => context[:account]})
    end
  end

end
