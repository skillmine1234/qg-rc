require 'spec_helper'

describe RcTransfersController do
  include HelperMethods
  
  before(:each) do
    @controller.instance_eval { flash.extend(DisableFlashSweeping) }
    sign_in @user = Factory(:user)
    Factory(:user_role, :user_id => @user.id, :role_id => Factory(:role, :name => 'editor').id)
    request.env["HTTP_REFERER"] = "/"
  end
  
  describe "GET index" do
    it "assigns all rc_transfers as @rc_transfers" do
      rc_transfer = Factory(:rc_transfer)
      get :index
      assigns(:records).should eq([rc_transfer])
    end
  end
  
  describe "GET show" do
    it "assigns the requested rc_transfer as @rc_transfer" do
      rc_transfer = Factory(:rc_transfer)
      get :show, {:id => rc_transfer.id}
      assigns(:rc_transfer).should eq(rc_transfer)
    end
  end

  describe "GET rc_audit_logs" do
    it "returns the all log" do
      rc_transfer = Factory(:rc_transfer)
      log = Factory(:rc_audit_step, :rc_auditable => rc_transfer, :step_name => 'CREDIT')
      params = rc_transfer.attributes.slice(*rc_transfer.class.attribute_names)
      get :audit_steps, :id => rc_transfer.id, :step_name => 'ALL'
      assigns[:record_values].should == [log]
    end

    it "returns the notify log" do
      rc_transfer = Factory(:rc_transfer)
      log1 = Factory(:rc_audit_step, :rc_auditable => rc_transfer, :step_no => 1, :attempt_no => 1, :step_name => 'CREDIT')
      log2 = Factory(:rc_audit_step, :rc_auditable => rc_transfer, :step_no => 2, :attempt_no => 2, :step_name => 'NOTIFY')
      params = rc_transfer.attributes.slice(*rc_transfer.class.attribute_names)
      get :audit_steps, :id => rc_transfer.id, :step_name => 'NOTIFY'
      assigns[:record_values].should == [log2]
    end
  end

  describe "PUT update" do
    it "updates the requested rc_transfer" do
      rc_transfer = Factory(:rc_transfer, :pending_approval => 'Y', :notify_status => 'NOTIFICATION FAILED')
      params = rc_transfer.attributes.slice(*rc_transfer.class.attribute_names)
      put :update, :id => rc_transfer.id
      response.should be_redirect
      rc_transfer.reload
      rc_transfer.notify_status.should == 'PENDING NOTIFICATION'
      rc_transfer.pending_approval.should == 'N'
    end
  end

  describe "PUT update multiple" do
    it "updates the requested rc_transfer" do
      rc_transfer1 = Factory(:rc_transfer, :pending_approval => 'Y', :notify_status => 'NOTIFICATION FAILED')
      rc_transfer2 = Factory(:rc_transfer, :pending_approval => 'Y', :notify_status => 'NOTIFICATION FAILED')
      put :update_multiple, :rc_transfer_ids => [rc_transfer1.id, rc_transfer2.id]
      response.should be_redirect
      rc_transfer1.reload
      rc_transfer1.notify_status.should == 'PENDING NOTIFICATION'
      rc_transfer1.pending_approval.should == 'N'
      rc_transfer2.reload
      rc_transfer2.notify_status.should == 'PENDING NOTIFICATION'
      rc_transfer2.pending_approval.should == 'N'
    end
  end
end
