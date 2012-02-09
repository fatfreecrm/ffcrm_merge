module ::FatFreeCrmCrowd
  class Engine < Rails::Engine
    config.to_prepare do
      require 'find'
      Find.find(File.join(File.dirname(__FILE__), '..', '..', 'app_extensions')) do |file|
        require file if file.end_with?('.rb')
      end
    end
  end
end
