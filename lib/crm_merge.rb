require 'crm_merge/merge_view_hooks'
require 'crm_merge/accounts'
require 'crm_merge/contacts'

# Require *.rb from app_extensions
require 'find'
Find.find(File.join(File.dirname(__FILE__), '..', 'app_extensions')) do |file|
  require file if file.end_with?(".rb")
end

