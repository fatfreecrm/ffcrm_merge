source 'https://rubygems.org'

gemspec

gem "fat_free_crm", git: 'https://github.com/fatfreecrm/fat_free_crm.git'
# gem 'responds_to_parent', git: 'https://github.com/CloCkWeRX/responds_to_parent.git', branch: 'patch-2' # Temporarily pointed at git until https://github.com/zendesk/responds_to_parent/pull/7 is released
gem 'acts_as_commentable', git: 'https://github.com/fatfreecrm/acts_as_commentable.git'
gem 'csv'
gem "devise-security"
gem "rack-attack"
gem "sparql-client"
gem "addressable"
gem "validates_lengths_from_database"

group :development, :test do
  gem "jquery-rails" # jquery-rails is used by the dummy application
  gem "factory_bot_rails" # Including here ensures 'fat_free_crm' factories are loading into spec/dummy
  gem 'bootstrap', '5.3.5' # for request specs
  gem 'coffee-rails', '5.0.0' # for request specs
  gem "sassc-rails" # for request specs
  gem "mini_racer"
  gem "puma"
end
