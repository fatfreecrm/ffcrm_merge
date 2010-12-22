require "fat_free_crm"

FatFreeCRM::Plugin.register(:crm_merge, initializer) do
          name "Fat Free CRM - Merge Contacts & Accounts"
        author "Nathan Broadbent"
       version "1.2"
   description "Basic contact & account merging"
   dependencies :haml, :simple_column_search
end

require "crm_merge"
