begin
  require File.dirname(__FILE__) + '/../../../../spec/spec_helper'
rescue LoadError
  puts "You need to install rspec in your base app"
  exit
end

require File.expand_path(File.dirname(__FILE__) + "/factories.rb")

# Require crm_super_tags factories if plugin is also installed
if File.exist?(File.dirname(__FILE__) + "/../../crm_super_tags")
  require File.dirname(__FILE__) + "/../../crm_super_tags/spec/factories.rb"
end


plugin_spec_dir = File.dirname(__FILE__)
ActiveRecord::Base.logger = Logger.new(plugin_spec_dir + "/debug.log")

