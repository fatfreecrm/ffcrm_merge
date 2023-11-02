source 'https://rubygems.org'

gemspec

gem "fat_free_crm", git: 'https://github.com/fatfreecrm/fat_free_crm.git'
gem 'responds_to_parent', git: 'https://github.com/CloCkWeRX/responds_to_parent.git', branch: 'patch-2' # Temporarily pointed at git until https://github.com/zendesk/responds_to_parent/pull/7 is released
gem 'acts_as_commentable', git: 'https://github.com/fatfreecrm/acts_as_commentable.git', branch: "rails-61"

group :development, :test do
  gem "jquery-rails" # jquery-rails is used by the dummy application
  gem "factory_bot_rails" # Including here ensures 'fat_free_crm' factories are loading into spec/dummy
  gem "byebug" unless ENV["CI"]
  gem 'bootstrap', '5.3.2' # for request specs
  gem 'coffee-rails', '5.0.0' # for request specs
  gem "sassc-rails" # for request specs
end
