module FatFreeCRM
  module Merge
    class Engine < ::Rails::Engine
    
      config.to_prepare do

        require 'ffcrm_merge/accounts'
        require 'ffcrm_merge/contacts'
        require 'ffcrm_merge/merge_view_hooks'

        require 'find'
        Find.find(File.join(File.dirname(__FILE__), 'extensions')) do |file|
          require file if file.end_with?('.rb')
        end
      end
      
      config.generators do |g|
        g.test_framework      :rspec,        :fixture => false
        g.fixture_replacement :factory_girl, :dir => 'spec/factories'
        g.assets false
        g.helper false
      end

    end
  end
end
