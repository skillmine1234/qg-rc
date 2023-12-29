require 'spec_helper'

describe RcTransferUnapprovedRecordsController do
  include HelperMethods
  
  before(:each) do
    @controller.instance_eval { flash.extend(DisableFlashSweeping) }
    sign_in @user = Factory(:user)
    Factory(:user_role, :user_id => @user.id, :role_id => Factory(:role, :name => 'editor').id)
    request.env["HTTP_REFERER"] = "/"
  end

  describe "GET index" do
    it "assigns all rc_transfer_unapproved_records as @rc_transfer_unapproved_records" do
      rc_transfer_unapproved_record = Factory(:rc_transfer_unapproved_record, :rc_transfer_approvable_type => 'RcTransferSchedule')
      get :index
      assigns(:records).should eq([{:record_type=>"RcTransferSchedule", :record_count=>1}, {:record_type=>"RcApp", :record_count=>0}])
    end
  end
end