require "fat_free_crm"

FatFreeCRM::Plugin.register(:crm_merge_contacts, self) do
          name "Fat Free Merge Contacts"
        author "Nathan Broadbent"
       version "1.2"
   description "Basic contact merging"
<<<<<<< HEAD
   dependencies :haml
=======
  dependencies :haml, :simple_column_search
>>>>>>> 11997a5df1ce54af47830e71d0b37979a481ed1a
end

require "crm_merge_contacts"

Rails.configuration.middleware.insert_before ::Rack::Lock, ::ActionDispatch::Static, "#{root}/public"

