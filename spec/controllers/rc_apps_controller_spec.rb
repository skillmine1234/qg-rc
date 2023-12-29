require 'spec_helper'

describe RcAppsController do
  include HelperMethods
  
  before(:each) do
    @controller.instance_eval { flash.extend(DisableFlashSweeping) }
    sign_in @user = Factory(:user)
    Factory(:user_role, :user_id => @user.id, :role_id => Factory(:role, :name => 'editor').id)
    request.env["HTTP_REFERER"] = "/"
  end

  describe "GET show" do
    it "assigns the requested rc_app as @rc_app" do
      rc_app = Factory(:rc_app)
      get :show, {:id => rc_app.id}
      assigns(:rc_app).should eq(rc_app)
    end
  end
  
  describe "GET index" do
    it "assigns all rc_apps as @rc_apps" do
      rc_app = Factory(:rc_app, :approval_status => 'A')
      get :index
      assigns(:rc_apps).should eq([rc_app])
    end
    
    it "assigns all unapproved rc_apps as @rc_apps when approval_status is passed" do
      rc_app = Factory(:rc_app, :approval_status => 'U')
      get :index, :approval_status => 'U'
      assigns(:rc_apps).should eq([rc_app])
    end
  end
  
  describe "GET edit" do
    it "assigns the requested rc_app as @rc_app" do
      rc_app = Factory(:rc_app, :approval_status => 'A')
      get :edit, {:id => rc_app.id}
      assigns(:rc_app).should eq(rc_app)
    end
    
    it "assigns the requested rc_app with status 'A' as @rc_app" do
      rc_app = Factory(:rc_app,:approval_status => 'A')
      get :edit, {:id => rc_app.id}
      assigns(:rc_app).should eq(rc_app)
    end

    it "assigns the new rc_app with requested rc_app params when status 'A' as @rc_app" do
      rc_app = Factory(:rc_app,:approval_status => 'A')
      params = (rc_app.attributes).merge({:approved_id => rc_app.id,:approved_version => rc_app.lock_version})
      get :edit, {:id => rc_app.id}
      assigns(:rc_app).should eq(RcApp.new(params))
    end
  end
  
  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested rc_app" do
        rc_app = Factory(:rc_app, :url => "http://localhost")
        params = rc_app.attributes.slice(*rc_app.class.attribute_names)
        params[:url] = "https://www.google.com"
        put :update, {:id => rc_app.id, :rc_app => params}
        rc_app.reload
        rc_app.url.should == "https://www.google.com"
      end

      it "assigns the requested rc_app as @rc_app" do
        rc_app = Factory(:rc_app, :url => "http://localhost")
        params = rc_app.attributes.slice(*rc_app.class.attribute_names)
        params[:url] = "https://www.google.com"
        put :update, {:id => rc_app.to_param, :rc_app => params}
        assigns(:rc_app).should eq(rc_app)
      end

      it "redirects to the rc_app" do
        rc_app = Factory(:rc_app, :url => "http://localhost")
        params = rc_app.attributes.slice(*rc_app.class.attribute_names)
        params[:url] = "https://www.google.com"
        put :update, {:id => rc_app.to_param, :rc_app => params}
        response.should redirect_to(rc_app)
      end

      it "should raise error when tried to update at same time by many" do
        rc_app = Factory(:rc_app, :url => "http://localhost")
        params = rc_app.attributes.slice(*rc_app.class.attribute_names)
        params[:url] = "https://www.google.com"
        rc_app2 = rc_app
        put :update, {:id => rc_app.id, :rc_app => params}
        rc_app.reload
        rc_app.url.should == "https://www.google.com"
        params[:url] = "https://www.yahoo.com"
        put :update, {:id => rc_app2.id, :rc_app => params}
        rc_app.reload
        rc_app.url.should == "https://www.google.com"
        flash[:alert].should  match(/Someone edited the rc_app the same time you did. Please re-apply your changes to the rc_app/)
      end
    end

    describe "with invalid params" do
      it "assigns the rc_app as @rc_app" do
        rc_app = Factory(:rc_app, :url => "http://localhost")
        params = rc_app.attributes.slice(*rc_app.class.attribute_names)
        params[:url] = nil
        put :update, {:id => rc_app.to_param, :rc_app => params}
        assigns(:rc_app).should eq(rc_app)
        rc_app.reload
        params[:url] = nil
      end

      it "re-renders the 'edit' template when show_errors is true" do
        rc_app = Factory(:rc_app)
        params = rc_app.attributes.slice(*rc_app.class.attribute_names)
        params[:url] = nil
        put :update, {:id => rc_app.id, :rc_app => params, :show_errors => "true"}
        response.should render_template("edit")
      end
    end
  end
  
  describe "POST create" do
    describe "with valid params" do
      it "creates a new rc_app" do
        params = Factory.attributes_for(:rc_app)
        expect {
          post :create, {:rc_app => params}
        }.to change(RcApp.unscoped, :count).by(1)
        flash[:alert].should  match(/Rc App successfully created and is pending for approval/)
        response.should be_redirect
      end

      it "assigns a newly created rc_app as @rc_app" do
        params = Factory.attributes_for(:rc_app)
        post :create, {:rc_app => params}
        assigns(:rc_app).should be_a(RcApp)
        assigns(:rc_app).should be_persisted
      end

      it "redirects to the created rc_app" do
        params = Factory.attributes_for(:rc_app)
        post :create, {:rc_app => params}
        response.should redirect_to(RcApp.unscoped.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved rc_app as @rc_app" do
        params = Factory.attributes_for(:rc_app)
        params[:url] = nil
        expect {
          post :create, {:rc_app => params}
        }.to change(RcApp, :count).by(0)
        assigns(:rc_app).should be_a(RcApp)
        assigns(:rc_app).should_not be_persisted
      end

      it "re-renders the 'new' template when show_errors is true" do
        params = Factory.attributes_for(:rc_app)
        params[:url] = nil
        post :create, {:rc_app => params}
        response.should render_template("edit")
      end
    end
  end
  
  describe "PUT approve" do
    it "(edit) unapproved record can be approved and old approved record will be updated" do
      user_role = UserRole.find_by_user_id(@user.id)
      user_role.delete
      Factory(:user_role, :user_id => @user.id, :role_id => Factory(:role, :name => 'supervisor').id)
      rc_app1 = Factory(:rc_app, :approval_status => 'A')
      rc_app2 = Factory(:rc_app, :approval_status => 'U', :url => "http://localhost", :approved_version => rc_app1.lock_version, :approved_id => rc_app1.id, :created_by => 666)
      # the following line is required for reload to get triggered (TODO)
      rc_app1.approval_status.should == 'A'
      RcTransferUnapprovedRecord.count.should == 1
      put :approve, {:id => rc_app2.id}
      RcTransferUnapprovedRecord.count.should == 0
      rc_app1.reload
      rc_app1.url.should == 'http://localhost'
      rc_app1.updated_by.should == "666"
      RcTransferUnapprovedRecord.find_by_id(rc_app2.id).should be_nil
    end
  end
  
  describe "GET audit_logs" do
    it "assigns the requested rc_app as @rc_app" do
      rc_app = Factory(:rc_app)
      get :audit_logs, {:id => rc_app.id, :version_id => 0}
      assigns(:rc_app).should eq(rc_app)
      assigns(:audit).should eq(rc_app.audits.first)
      get :audit_logs, {:id => 12345, :version_id => "i"}
      assigns(:rc_app).should eq(nil)
      assigns(:audit).should eq(nil)
    end
  end
end
