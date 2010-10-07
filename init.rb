require "fat_free_crm"

FatFreeCRM::Plugin.register(:crm_merge_contacts, self) do
          name "Fat Free Merge Contacts"
        author "Nathan Broadbent"
       version "1.2"
   description "Basic contact merging"
   dependencies :haml
end

require "crm_merge_contacts"

Rails.configuration.middleware.insert_before ::Rack::Lock, ::ActionDispatch::Static, "#{root}/public"

