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
        flash[:warning].should_not == nil
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
end

