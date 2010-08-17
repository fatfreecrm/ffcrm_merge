require File.join(File.dirname(__FILE__), 'merge', 'contacts')
require File.join(File.dirname(__FILE__), 'merge', 'merge_view_hooks')

# Require *.rb from app_extensions
require 'find'
Find.find(File.join(File.dirname(__FILE__), '..', 'app_extensions')) do |file|
  require file if file.end_with?(".rb")
end

