module FfcrmMerge
  class Engine < ::Rails::Engine
  
    config.to_prepare do

      # Override various parts of fat_free_crm when they are loaded

      ActiveSupport.on_load(:fat_free_crm_account) do
        require 'ffcrm_merge/accounts'
        include FfcrmMerge::Accounts
      end

      ActiveSupport.on_load(:fat_free_crm_contact) do
        require 'ffcrm_merge/contacts'
        include FfcrmMerge::Contacts
      end

      ActiveSupport.on_load(:action_view) do
        require 'ffcrm_merge/merge_view_hooks'
      end

      require 'ffcrm_merge/redirect_to_merged_record'
      AccountsController.include( FfcrmMerge::RedirectToMergedRecord )
      ContactsController.include( FfcrmMerge::RedirectToMergedRecord )

    end

    initializer :append_migrations do |app|
      unless "#{root}/spec/dummy" == app.root.to_s
        config.paths["db/migrate"].expanded.each do |expanded_path|
          app.config.paths["db/migrate"] << expanded_path
        end
      end
    end

    config.generators do |g|
      g.test_framework      :rspec,       fixture: false
      g.fixture_replacement :factory_bot, dir: 'spec/factories'
      g.assets false
      g.helper false
    end

  end
end
