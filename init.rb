require "fat_free_crm"

FatFreeCRM::Plugin.register(:crm_merge_contacts, initializer) do
          name "Fat Free Merge Contacts"
        author "Nathan Broadbent"
       version "0.1"
   description "Basic contact merging"
end

# Require Merge modules
require File.join(File.dirname(__FILE__), 'lib', 'merge_contacts.rb')

# Require *.rb from app_extensions
require 'find'
Find.find(File.join(File.dirname(__FILE__), 'app_extensions')) do |file|
  require file if file.end_with?(".rb")
end

