FactoryBot.define do

  factory :contact_alias do
    contact
    destroyed_contact_id { rand(1000000).to_i }
    updated_at           { FactoryBot.generate(:time) }
    created_at           { FactoryBot.generate(:time) }
  end

end
