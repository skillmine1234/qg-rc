require 'spec_helper'

describe RcTransfersHelper do
  context "find_logs" do 
    it "should return audit_steps results" do 
      rc_transfer = Factory(:rc_transfer)
      a = Factory(:rc_audit_step, :rc_auditable => rc_transfer)
      params = {:id => rc_transfer.id, :step_name => "ALL"}
      find_logs(params,rc_transfer).should == [a]
    end
  end

  context "allow_retry" do
    it "should return true if retry is allowed" do
      rc_transfer_schedule = Factory(:rc_transfer_schedule, code: '1111', last_batch_no: 1, approval_status: 'A')
      rc_transfer = Factory(:rc_transfer, rc_transfer_code: '1111', batch_no: 1, status_code: 'BALINQ FAILED', max_retries: 2, attempt_no: 2)
      allow_retry(rc_transfer).should == true
    end
    
    it "should return false if retry is not allowed" do
      rc_transfer_schedule = Factory(:rc_transfer_schedule, code: '1111', last_batch_no: 1, approval_status: 'A')
      rc_transfer1 = Factory(:rc_transfer, rc_transfer_code: '1111', batch_no: 2, status_code: 'BALINQ FAILED', max_retries: 2, attempt_no: 2)
      allow_retry(rc_transfer1).should == false

      rc_transfer2 = Factory(:rc_transfer, rc_transfer_code: '1111', batch_no: 1, status_code: 'CREDITED', max_retries: 2, attempt_no: 2)
      allow_retry(rc_transfer2).should == false

      rc_transfer3 = Factory(:rc_transfer, rc_transfer_code: '1111', batch_no: 1, status_code: 'BALINQ FAILED', max_retries: 3, attempt_no: 2)
      allow_retry(rc_transfer3).should == false
    end
  end
end
