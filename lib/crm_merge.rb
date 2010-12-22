# Require all files in lib/crm_merge plugin directory
Dir.glob(File.join(File.dirname(__FILE__), "crm_merge", "*.rb")).each {|f| require f }

# Require all files in lib/crm_merge/(controllers || helpers || models) plugin directory
Dir.glob(File.join(File.dirname(__FILE__), "crm_merge", "**", "*.rb")).each {|f| require f }
