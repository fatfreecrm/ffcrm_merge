class MergeViewHooks < FatFreeCRM::Callback::Base

  def javascript_epilogue(view, context = {})
    # Load the crm_merge.js file in the same directory.
    File.open(File.join(File.dirname(__FILE__), 'crm_merge.js'), 'r').read
  end

end

