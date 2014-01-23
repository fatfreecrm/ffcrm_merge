source 'https://rubygems.org'

gemspec

gem 'fat_free_crm', git: 'fatfreecrm/fat_free_crm', branch: 'master'

group :test do
  gem 'pg'  # Default database for testing
  gem 'debugger' unless ENV["CI"]
end
