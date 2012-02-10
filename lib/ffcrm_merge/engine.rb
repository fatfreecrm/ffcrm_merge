module ::FatFreeCrmMerge
  class Engine < Rails::Engine
    initializer "ffcrm_merge.boot" do
      require 'find'
      
      Find.find(File.join(File.dirname(__FILE__), 'extensions')) do |file|
        require file if file.end_with?('.rb')
      end
    end
  end
end
