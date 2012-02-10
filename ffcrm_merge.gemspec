# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'ffcrm_merge/version'

Gem::Specification.new do |s|
  s.name = 'ffcrm_merge'
  s.authors = ['Nathan Broadbent']
  s.summary = 'Fat Free CRM - Merge Contacts & Accounts'
  s.description = 'Fat Free CRM - Merge Contacts & Accounts'
  s.files = `git ls-files`.split("\n")
  s.version = FatFreeCRM::Merge::VERSION

  s.add_development_dependency 'rspec-rails', '~> 2.6'
  s.add_development_dependency 'capybara'
  s.add_development_dependency 'combustion'
  s.add_dependency 'fat_free_crm'
end
