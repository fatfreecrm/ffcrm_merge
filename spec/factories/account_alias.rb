FactoryGirl.define do
  factory :account_alias do
    account
    destroyed_account_id { rand(1000000).to_i }
    updated_at           { FactoryGirl.generate(:time) }
    created_at           { FactoryGirl.generate(:time) }
  end
end
