require 'spec_helper'

describe AccountAlias do

  describe "ids_with_alias" do
  
    before(:each) do
      @account1 = FactoryGirl.create(:account)
      @account2 = FactoryGirl.create(:account)
      FactoryGirl.create(:account_alias, :destroyed_account_id => 21, :account_id => @account1.id)
    end
  
    it "should replace a list of alias ids with the correct id" do
      ids = ['21', "#{@account2.id}"]
      id1 = @account1.id.to_s
      id2 = @account2.id.to_s
      expect(AccountAlias.ids_with_alias(ids)).to eql( {"21" => id1, id2 => id2} )
    end
    
    it "should not repeat values" do
      ids = ['21', "#{@account2.id}", '21']
      id1 = @account1.id.to_s
      id2 = @account2.id.to_s
      expect(AccountAlias.ids_with_alias(ids)).to eql( {"21" => id1, id2 => id2} )
    end
    
    # Say 21 is merged into 22 and 22 is merged into 23, then: 21 => 23 and 22 => 23
    it "should handle multiple merges" do
      FactoryGirl.create(:account_alias, :destroyed_account_id => 22, :account_id => @account1.id)
      ids = ['21', '22']
      id1 = @account1.id.to_s
      expect(AccountAlias.ids_with_alias(ids)).to eql( {"21" => id1, "22" => id1} )
    end
    
    it "should return a empty hash when given nil" do
      expect(AccountAlias.ids_with_alias(nil)).to eql({})
    end
    
    it "should return a empty hash when given empty list of ids" do
      expect(AccountAlias.ids_with_alias([])).to eql({})
    end
  
  end

end
