# Include Merge::Contacts methods on Contact model
Contact.class_eval do
  include Merge::Contacts
end

