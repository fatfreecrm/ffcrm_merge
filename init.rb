require "fat_free_crm"

FatFreeCRM::Plugin.register(:crm_merge, self) do
          name "Fat Free CRM - Merge Contacts & Accounts"
        author "Nathan Broadbent"
       version "1.2"
   description "Basic contact & account merging"
   dependencies :haml
end

require "crm_merge"

Rails.configuration.middleware.insert_before ::Rack::Lock, ::ActionDispatch::Static, "#{root}/public"

