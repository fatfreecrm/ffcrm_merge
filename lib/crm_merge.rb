# Require all files in lib/crm_* plugin directory
Dir.glob(File.join(File.dirname(__FILE__), "crm_*", "*.rb")).each {|f| require f }

# Require *.rb from app_extensions
require 'find'
Find.find(File.join(File.dirname(__FILE__), '..', 'app_extensions')) do |file|
  require file if file.end_with?(".rb")
end
