require "fat_free_crm"

FatFreeCRM::Plugin.register(:crm_merge_contacts, initializer) do
          name "Fat Free Merge Contacts"
        author "Nathan Broadbent"
       version "1.0"
   description "Basic contact merging"
   dependencies :haml, :simple_column_search
end

require "crm_merge_contacts"

