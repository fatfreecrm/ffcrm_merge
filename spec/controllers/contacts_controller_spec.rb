require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ContactsController do
  before(:each) do
    require_user
    set_current_tab(:contacts)
  end

  describe "destroyed contact aliases" do
    # GET /contacts/1
    # GET /contacts/1.xml                                                    HTML
    #----------------------------------------------------------------------------
    describe "responding to SHOW request" do
      before(:each) do
        @contact = Factory(:contact, :id => 9999)
        @contact_alias = Factory(:contact_alias,
                                 :contact => @contact,
                                 :destroyed_contact_id => 10000)
        @stage = Setting.unroll(:opportunity_stage)
        @comment = Comment.new
      end

      it "should find a destroyed contact from the " do
        get :show, :id => 10000, :format => "xml"
        assigns[:contact].should == @contact
      end

      it "should redirect to contact index if contact cannot be found anywhere" do
        @contact = Factory(:contact, :user => @current_user).destroy

        get :show, :id => @contact.id
        response.should redirect_to(contacts_path)
      end
    end

    # PUT /contacts/1
    # PUT /contacts/1.xml                                                    AJAX
    #----------------------------------------------------------------------------
    describe "responding to PUT update" do
      it "should update an aliased contact" do
        @contact = Factory(:contact,
                           :id => 7878,
                           :first_name => "Billy")
        @contact_alias = Factory(:contact_alias,
                                 :contact => @contact,
                                 :destroyed_contact_id => 1234)

        xhr :put, :update, :id => 1234,
                           :contact => { :first_name => "Bones" },
                           :account => {}

        @contact.reload.first_name.should == "Bones"
        assigns(:contact).should == @contact
        response.should render_template("contacts/update")
      end
    end

  end

  describe "auto complete with ignored ids param" do
    before(:each) do
      @matched = (1..5).map{|i| Factory(:contact,
                                        :first_name => "Test",
                                        :id => i)}
      @ignored = (6..7).map{|i| Factory(:contact,
                                        :first_name => "Test",
                                        :id => i)}
    end

    # POST /contacts/auto_complete/query                                     AJAX
    #----------------------------------------------------------------------------
    it "should be able to function without the ignored param" do
      post :auto_complete, :auto_complete_query => "Test"
      assigns[:query].should == "Test"
      # Should return all @matched and @ignored contacts
      # (test the sorted results)
      sorted_result = assigns[:auto_complete].sort{|a,b| a.id <=> b.id}
      sorted_result.should == (@matched + @ignored)
    end

    # POST /contacts/auto_complete/query?ignored=6,7                                   AJAX
    #----------------------------------------------------------------------------
    it "should be able to ignore given ids" do
      post :auto_complete, :auto_complete_query => "Test",
                           :ignored => "6,7"
      assigns[:query].should == "Test"
      # Should not include @ignored contacts
      # (test the sorted results)
      sorted_result = assigns[:auto_complete].sort {|a,b| a.id <=> b.id}
      sorted_result.should == @matched
    end
  end
end

