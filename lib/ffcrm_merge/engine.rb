module FfcrmMerge
  class Engine < ::Rails::Engine
  
    config.to_prepare do
      require 'ffcrm_merge/accounts'
      Account.class_eval do
        include FfcrmMerge::Accounts
      end
      
      require 'ffcrm_merge/contacts'
      Contact.class_eval do
        include FfcrmMerge::Contacts
      end

      require 'ffcrm_merge/merge_view_hooks'
      require 'ffcrm_merge/merge_not_found_controller'

    end
    
    config.generators do |g|
      g.test_framework      :rspec,        :fixture => false
      g.fixture_replacement :factory_girl, :dir => 'spec/factories'
      g.assets false
      g.helper false
    end

  end
end
