require 'spec_helper'

describe RcTransferUnapprovedRecordsHelper do
  context "filter_records" do 
    it "should return records" do
      rc_transfer_unapproved_record = Factory(:rc_transfer_unapproved_record, :rc_transfer_approvable_type => 'RcTransferSchedule')
      filter_records(RcTransferUnapprovedRecord).should eq([{:record_type=>"RcTransferSchedule", :record_count=>1}, {:record_type=>"RcApp", :record_count=>0}])
    end
  end
end
