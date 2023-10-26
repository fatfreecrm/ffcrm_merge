FactoryBot.define do

  factory :account_alias do
    account
    destroyed_account_id { rand(1000000).to_i }
    updated_at           { FactoryBot.generate(:time) }
    created_at           { FactoryBot.generate(:time) }
  end

end
