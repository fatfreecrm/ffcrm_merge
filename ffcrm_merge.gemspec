# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'ffcrm_merge/version'

Gem::Specification.new do |s|
  s.name = 'ffcrm_merge'
  s.authors = ['Nathan Broadbent', 'Steve Kenworthy']
  s.summary = 'Fat Free CRM - Merge Contacts & Accounts'
  s.description = 'Fat Free CRM - Merge Contacts & Accounts'
  s.files = `git ls-files`.split("\n")
  s.test_files = Dir["spec/**/*"]
  s.version = FfcrmMerge::VERSION

  s.add_development_dependency 'rspec-rails', '>= 2.12.2'
  s.add_development_dependency 'capybara'
  s.add_development_dependency 'factory_girl_rails'
  s.add_development_dependency 'ffaker'
  s.add_development_dependency 'database_cleaner'
  s.add_dependency 'fat_free_crm'
  
end
