require 'spec_helper'

describe RcTransferSchedulesController do
  include HelperMethods
  
  before(:each) do
    @controller.instance_eval { flash.extend(DisableFlashSweeping) }
    sign_in @user = Factory(:user)
    Factory(:user_role, :user_id => @user.id, :role_id => Factory(:role, :name => 'editor').id)
    request.env["HTTP_REFERER"] = "/"
  end

  describe "GET index" do
    it "assigns all rc_transfer_schedules as @rc_transfer_schedules" do
      rc_transfer_schedule = Factory(:rc_transfer_schedule, :approval_status => 'A')
      get :index
      assigns(:records).should eq([rc_transfer_schedule])
    end

    it "assigns all unapproved rc_transfer_schedules as @rc_transfer_schedules when approval_status is passed" do
      rc_transfer_schedule = Factory(:rc_transfer_schedule, :approval_status => 'U')
      get :index, :approval_status => 'U'
      assigns(:records).should eq([rc_transfer_schedule])
    end
  end

  describe "GET show" do
    it "assigns the requested rc_transfer_schedule as @rc_transfer_schedule" do
      rc_transfer_schedule = Factory(:rc_transfer_schedule)
      get :show, {:id => rc_transfer_schedule.id}
      assigns(:rc_transfer_schedule).should eq(rc_transfer_schedule)
    end
  end

  describe "GET new" do
    it "assigns a new rc_transfer_schedule as @rc_transfer_schedule" do
      get :new
      assigns(:rc_transfer_schedule).should be_a_new(RcTransferSchedule)
    end
  end

  describe "GET edit" do
    it "assigns the requested rc_transfer_schedule with status 'U' as @rc_transfer_schedule" do
      rc_transfer_schedule = Factory(:rc_transfer_schedule, :approval_status => 'U')
      get :edit, {:id => rc_transfer_schedule.id}
      assigns(:rc_transfer_schedule).should eq(rc_transfer_schedule)
    end

    it "assigns the requested rc_transfer_schedule with status 'A' as @rc_transfer_schedule" do
      rc_transfer_schedule = Factory(:rc_transfer_schedule,:approval_status => 'A')
      get :edit, {:id => rc_transfer_schedule.id}
      assigns(:rc_transfer_schedule).should eq(rc_transfer_schedule)
    end

    it "assigns the new rc_transfer_schedule with requested rc_transfer_schedule params when status 'A' as @rc_transfer_schedule" do
      rc_transfer_schedule = Factory(:rc_transfer_schedule,:approval_status => 'A')
      params = (rc_transfer_schedule.attributes).merge({:approved_id => rc_transfer_schedule.id,:approved_version => rc_transfer_schedule.lock_version})
      get :edit, {:id => rc_transfer_schedule.id}
      assigns(:rc_transfer_schedule).should eq(RcTransferSchedule.new(params))
    end
  end
  
  describe "POST create" do
    describe "with valid params" do
      it "creates a new rc_transfer_schedule" do
        params = Factory.attributes_for(:rc_transfer_schedule)
        expect {
          post :create, {:rc_transfer_schedule => params}
        }.to change(RcTransferSchedule.unscoped, :count).by(1)
        flash[:alert].should  match(/Rc Transfer Schedule successfully created and is pending for approval/)
        response.should be_redirect
      end

      it "assigns a newly created rc_transfer_schedule as @rc_transfer_schedule" do
        params = Factory.attributes_for(:rc_transfer_schedule)
        post :create, {:rc_transfer_schedule => params}
        assigns(:rc_transfer_schedule).should be_a(RcTransferSchedule)
        assigns(:rc_transfer_schedule).should be_persisted
      end

      it "redirects to the created rc_transfer_schedule" do
        params = Factory.attributes_for(:rc_transfer_schedule)
        post :create, {:rc_transfer_schedule => params}
        response.should redirect_to(RcTransferSchedule.unscoped.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved rc_transfer_schedule as @rc_transfer_schedule" do
        params = Factory.attributes_for(:rc_transfer_schedule)
        params[:code] = nil
        expect {
          post :create, {:rc_transfer_schedule => params}
        }.to change(RcTransferSchedule, :count).by(0)
        assigns(:rc_transfer_schedule).should be_a(RcTransferSchedule)
        assigns(:rc_transfer_schedule).should_not be_persisted
      end

      it "re-renders the 'new' template when show_errors is true" do
        params = Factory.attributes_for(:rc_transfer_schedule)
        params[:code] = nil
        post :create, {:rc_transfer_schedule => params}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested rc_transfer_schedule" do
        rc_transfer_schedule = Factory(:rc_transfer_schedule, :debit_account_no => "8877665544332211")
        params = rc_transfer_schedule.attributes.slice(*rc_transfer_schedule.class.attribute_names)
        params[:debit_account_no] = "8877665544332212"
        put :update, {:id => rc_transfer_schedule.id, :rc_transfer_schedule => params}
        rc_transfer_schedule.reload
        rc_transfer_schedule.debit_account_no.should == "8877665544332212"
      end

      it "assigns the requested rc_transfer_schedule as @rc_transfer_schedule" do
        rc_transfer_schedule = Factory(:rc_transfer_schedule, :debit_account_no => "8877665544332213")
        params = rc_transfer_schedule.attributes.slice(*rc_transfer_schedule.class.attribute_names)
        params[:debit_account_no] = "8877665544332214"
        put :update, {:id => rc_transfer_schedule.to_param, :rc_transfer_schedule => params}
        assigns(:rc_transfer_schedule).should eq(rc_transfer_schedule)
      end

      it "redirects to the rc_transfer_schedule" do
        rc_transfer_schedule = Factory(:rc_transfer_schedule, :debit_account_no => "8877665544332215")
        params = rc_transfer_schedule.attributes.slice(*rc_transfer_schedule.class.attribute_names)
        params[:debit_account_no] = "8877665544332216"
        put :update, {:id => rc_transfer_schedule.to_param, :rc_transfer_schedule => params}
        response.should redirect_to(rc_transfer_schedule)
      end

      it "should raise error when tried to update at same time by many" do
        rc_transfer_schedule = Factory(:rc_transfer_schedule, :debit_account_no => "8877665544332217")
        params = rc_transfer_schedule.attributes.slice(*rc_transfer_schedule.class.attribute_names)
        params[:debit_account_no] = "8877665544332218"
        rc_transfer_schedule2 = rc_transfer_schedule
        put :update, {:id => rc_transfer_schedule.id, :rc_transfer_schedule => params}
        rc_transfer_schedule.reload
        rc_transfer_schedule.debit_account_no.should == "8877665544332218"
        params[:debit_account_no] = "8877665544332219"
        put :update, {:id => rc_transfer_schedule2.id, :rc_transfer_schedule => params}
        rc_transfer_schedule.reload
        rc_transfer_schedule.debit_account_no.should == "8877665544332218"
        flash[:alert].should  match(/Someone edited the Rc Transfer Schedule the same time you did. Please re-apply your changes to the Rc Transfer Schedule/)
      end
    end

    describe "with invalid params" do
      it "assigns the rc_transfer_schedule as @rc_transfer_schedule" do
        rc_transfer_schedule = Factory(:rc_transfer_schedule, :debit_account_no => "8877665544332220")
        params = rc_transfer_schedule.attributes.slice(*rc_transfer_schedule.class.attribute_names)
        params[:debit_account_no] = nil
        put :update, {:id => rc_transfer_schedule.to_param, :rc_transfer_schedule => params}
        assigns(:rc_transfer_schedule).should eq(rc_transfer_schedule)
        rc_transfer_schedule.reload
        params[:debit_account_no] = nil
      end

      it "re-renders the 'edit' template when show_errors is true" do
        rc_transfer_schedule = Factory(:rc_transfer_schedule)
        params = rc_transfer_schedule.attributes.slice(*rc_transfer_schedule.class.attribute_names)
        params[:code] = nil
        put :update, {:id => rc_transfer_schedule.id, :rc_transfer_schedule => params, :show_errors => "true"}
        response.should render_template("edit")
      end
    end
  end
 
  describe "GET audit_logs" do
    it "assigns the requested rc_transfer_schedule as @rc_transfer_schedule" do
      rc_transfer_schedule = Factory(:rc_transfer_schedule)
      get :audit_logs, {:id => rc_transfer_schedule.id, :version_id => 0}
      assigns(:rc_transfer_schedule).should eq(rc_transfer_schedule)
      assigns(:audit).should eq(rc_transfer_schedule.audits.first)
      get :audit_logs, {:id => 12345, :version_id => "i"}
      assigns(:rc_transfer_schedule).should eq(nil)
      assigns(:audit).should eq(nil)
    end
  end

  describe "PUT approve" do
    it "(edit) unapproved record can be approved and old approved record will be updated" do
      user_role = UserRole.find_by_user_id(@user.id)
      user_role.delete
      Factory(:user_role, :user_id => @user.id, :role_id => Factory(:role, :name => 'supervisor').id)
      rc_transfer_schedule1 = Factory(:rc_transfer_schedule, :approval_status => 'A')
      rc_transfer_schedule2 = Factory(:rc_transfer_schedule, :approval_status => 'U', :debit_account_no => '8877665544332221', :approved_version => rc_transfer_schedule1.lock_version, :approved_id => rc_transfer_schedule1.id, :created_by => 666)
      # the following line is required for reload to get triggered (TODO)
      rc_transfer_schedule1.approval_status.should == 'A'
      RcTransferUnapprovedRecord.count.should == 1
      put :approve, {:id => rc_transfer_schedule2.id}
      RcTransferUnapprovedRecord.count.should == 0
      rc_transfer_schedule1.reload
      rc_transfer_schedule1.debit_account_no.should == '8877665544332221'
      rc_transfer_schedule1.updated_by.should == "666"
      RcTransferUnapprovedRecord.find_by_id(rc_transfer_schedule2.id).should be_nil
    end

    it "(create) unapproved record can be approved" do
      user_role = UserRole.find_by_user_id(@user.id)
      user_role.delete
      Factory(:user_role, :user_id => @user.id, :role_id => Factory(:role, :name => 'supervisor').id)
      rc_transfer_schedule = Factory(:rc_transfer_schedule, :debit_account_no => '8877665544332222', :approval_status => 'U')
      RcTransferUnapprovedRecord.count.should == 1
      put :approve, {:id => rc_transfer_schedule.id}
      RcTransferUnapprovedRecord.count.should == 0
      rc_transfer_schedule.reload
      rc_transfer_schedule.debit_account_no.should == '8877665544332222'
      rc_transfer_schedule.approval_status.should == 'A'
    end
  end
end
