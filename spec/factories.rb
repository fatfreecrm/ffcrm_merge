#----------------------------------------------------------------------------
Factory.define :contact_alias do |c|
  c.contact              { |a| a.association(:contact) }
  c.destroyed_contact_id { rand(1000000).to_i }
  c.updated_at           { Factory.next(:time) }
  c.created_at           { Factory.next(:time) }
end

