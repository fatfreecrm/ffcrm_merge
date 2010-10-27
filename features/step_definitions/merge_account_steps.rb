Given /^two duplicate accounts$/ do
  @dup_account = Factory(:account, :id         => 1,
                                   :name       => "Test Account One",
                                   :phone      => "1111-1111",
                                   :fax        => "(111)1111111111",
                                   :email      => "testuserone@example.com",
                                   :website    => "testuserone.com")

  @tasks = %w(One Two).map {|n| Factory(:task,   :asset => @dup_account,
                                                 :name  => "Test Task #{n}")}

  @emails = %w(One Two).map {|n| Factory(:email, :mediator => @dup_account,
                                                 :subject  => "Test Email #{n}")}

  @opportunities = %w(One Two).map {|n| Factory(:account_opportunity,
                                                :account => @dup_account,
                            :opportunity => Factory(:opportunity,
                                                    :name => "Test Opportunity #{n}",
                                                    :account => @dup_account))}

  @contacts = %w(One Two).map {|n| Factory(:contact, :first_name => "Test Contact",
                                                     :last_name => n,
                                                     :account => @dup_account)}

  @account = Factory(:account, :id         => 2,
                               :name       => "Test Account Two",
                               :phone      => "2222-2222",
                               :fax        => "(222)2222222222",
                               :email      => "testusertwo@example.com",
                               :website    => "testusertwo.com")
end
