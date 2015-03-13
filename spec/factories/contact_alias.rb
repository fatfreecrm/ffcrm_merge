FactoryGirl.define do
  factory :contact_alias do
    contact
    destroyed_contact_id { rand(1000000).to_i }
    updated_at           { FactoryGirl.generate(:time) }
    created_at           { FactoryGirl.generate(:time) }
  end
end
