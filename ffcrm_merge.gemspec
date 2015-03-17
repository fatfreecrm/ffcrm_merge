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

  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'capybara'
  s.add_development_dependency 'ffaker', '~> 1.0'
  s.add_development_dependency 'database_cleaner'
  s.add_dependency 'fat_free_crm', '>= 0.14.0'
end
