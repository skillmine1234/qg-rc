require 'spec_helper'

describe RcTransferSchedule do
  subject { Factory(:rc_transfer_schedule) }
  
  context 'association' do
    it { should belong_to(:created_user) }
    it { should belong_to(:updated_user) }
    it { should have_one(:rc_transfer_unapproved_record) }
    it { should belong_to(:unapproved_record) }
    it { should belong_to(:approved_record) }
    it { should belong_to(:rc_transfer) }
  end
  
  context 'validation' do
    [:code, :debit_account_no, :is_enabled, :max_retries, :retry_in_mins].each do |att|
      it { should validate_presence_of(att) }
    end

    it do
      should validate_length_of(:code).is_at_most(20)
      should validate_length_of(:debit_account_no).is_at_least(15).is_at_most(20)
      should validate_length_of(:bene_account_no).is_at_most(20)
      should validate_length_of(:notify_mobile_no).is_at_least(10).is_at_most(10)
      should validate_length_of(:bene_name).is_at_most(25)
    end

    it do 
      should validate_uniqueness_of(:code).scoped_to(:approval_status)
    end
    
    it do
      rc_transfer_schedule = Factory.build(:rc_transfer_schedule, bene_account_no: nil, bene_account_ifsc: 'YESB0123456', bene_name: nil, acct_threshold_amt: nil, txn_kind: 'FT')
      rc_transfer_schedule.save.should == false
      rc_transfer_schedule.errors_on(:bene_account_no).should == ["can't be blank when Transaction Kind is FT"]
      rc_transfer_schedule.errors_on(:bene_name).should == ["can't be blank when Transaction Kind is FT"]
      rc_transfer_schedule.errors_on(:acct_threshold_amt).should == ["can't be blank when Transaction Kind is FT"]
    end
    
    it { should validate_numericality_of(:interval_in_mins) }
    it { should validate_numericality_of(:max_retries) }
    it { should validate_numericality_of(:retry_in_mins) }

    it "should return error if code is already taken" do
      rc_transfer_schedule1 = Factory(:rc_transfer_schedule, :code => "9001", :approval_status => 'A')
      rc_transfer_schedule2 = Factory.build(:rc_transfer_schedule, :code => "9001", :approval_status => 'A')
      rc_transfer_schedule2.should_not be_valid
      rc_transfer_schedule2.errors_on(:code).should == ["has already been taken"]
    end

    it 'should not accept previos date for next run at' do 
      rc_transfer_schedule = Factory.build(:rc_transfer_schedule, :next_run_at => Time.zone.now.advance(:days => -1))
      rc_transfer_schedule.should_not be_valid
      rc_transfer_schedule.errors_on(:next_run_at).should == ["should not be less than today's date"]
      rc_transfer_schedule = Factory(:rc_transfer_schedule, :next_run_at => Time.zone.now.beginning_of_day)
      rc_transfer_schedule.should be_valid
      rc_transfer_schedule = Factory(:rc_transfer_schedule, :next_run_at => Time.zone.now)
      rc_transfer_schedule.should be_valid
      rc_transfer_schedule = Factory(:rc_transfer_schedule, :next_run_at => Time.zone.now.advance(:days => 1))
      rc_transfer_schedule.should be_valid
    end
    
    it "should give error when retry_in_mins < 15 and max_retries > 0" do
      rc_transfer_schedule = Factory.build(:rc_transfer_schedule, max_retries: 1, retry_in_mins: 5, interval_in_mins: 10)
      rc_transfer_schedule.should_not be_valid
      rc_transfer_schedule = Factory(:rc_transfer_schedule, max_retries: 1, retry_in_mins: 15, interval_in_mins: 40)
      rc_transfer_schedule.should be_valid
      rc_transfer_schedule = Factory(:rc_transfer_schedule, max_retries: 0, retry_in_mins: 10, interval_in_mins: 40)
      rc_transfer_schedule.should be_valid
    end
    
    it "should validate absence of bene ifsc and name if txn_kind is COLLECT" do
      rc_transfer_schedule = Factory.build(:rc_transfer_schedule, bene_account_ifsc: 'HDFC0123456', bene_name: 'John', txn_kind: 'COLLECT')
      rc_transfer_schedule.should_not be_valid
      rc_transfer_schedule.errors_on(:bene_account_ifsc).should == ['must be blank when Transaction Kind is COLLECT']
      rc_transfer_schedule.errors_on(:bene_name).should == ['must be blank when Transaction Kind is COLLECT']
      
      rc_transfer_schedule = Factory.build(:rc_transfer_schedule, bene_account_ifsc: nil, bene_name: nil, txn_kind: 'COLLECT')
      rc_transfer_schedule.should be_valid
    end
  end

  context "fields format" do
    it "should allow valid format" do
      [:code].each do |att|
        should allow_value('98765').for(att)
        should allow_value('ABCD90').for(att)
        should allow_value('abcd1234E').for(att)
      end

      [:debit_account_no, :bene_account_no].each do |att|
        should allow_value('123456789012345').for(att)
      end

      should allow_value('9988776655').for(:notify_mobile_no)
      
      should allow_value('ABCD0123456').for(:bene_account_ifsc)
      should allow_value('abcd0123456').for(:bene_account_ifsc)
    end

    it "should not allow invalid format" do
      rc_transfer_schedule = Factory.build(:rc_transfer_schedule, :code => "BANK-01", :debit_account_no => "ACC12345", :bene_account_no => "123-456", :notify_mobile_no => "+998877665", :bene_account_ifsc => '12340abcd')
      rc_transfer_schedule.save.should be_false
      rc_transfer_schedule.errors_on(:bene_account_no).should == ["Invalid format, expected format is : {[0-9]}"]
      rc_transfer_schedule.errors_on(:bene_account_ifsc).should == ["Invalid format, expected format is : {[A-Z|a-z]{4}[0][A-Za-z0-9]{6}}"]
    end
  end
  
  context "default_scope" do 
    it "should only return 'A' records by default" do 
      rc_transfer_schedule1 = Factory(:rc_transfer_schedule, :approval_status => 'A') 
      rc_transfer_schedule2 = Factory(:rc_transfer_schedule, :code => '1234567891')
      RcTransferSchedule.all.should == [rc_transfer_schedule1]
      rc_transfer_schedule2.approval_status = 'A'
      rc_transfer_schedule2.save
      RcTransferSchedule.all.should == [rc_transfer_schedule1,rc_transfer_schedule2]
    end
  end    

  context "rc_transfer_unapproved_records" do 
    it "oncreate: should create rc_transfer_unapproved_record if the approval_status is 'U'" do
      rc_transfer_schedule = Factory(:rc_transfer_schedule)
      rc_transfer_schedule.reload
      rc_transfer_schedule.rc_transfer_unapproved_record.should_not be_nil
    end

    it "oncreate: should not create rc_transfer_unapproved_record if the approval_status is 'A'" do
      rc_transfer_schedule = Factory(:rc_transfer_schedule, :approval_status => 'A')
      rc_transfer_schedule.rc_transfer_unapproved_record.should be_nil
    end

    it "onupdate: should not remove rc_transfer_unapproved_record if approval_status did not change from U to A" do
      rc_transfer_schedule = Factory(:rc_transfer_schedule)
      rc_transfer_schedule.reload
      rc_transfer_schedule.rc_transfer_unapproved_record.should_not be_nil
      record = rc_transfer_schedule.rc_transfer_unapproved_record
      # we are editing the U record, before it is approved
      rc_transfer_schedule.debit_account_no = '8877665544332211'
      rc_transfer_schedule.save
      rc_transfer_schedule.reload
      rc_transfer_schedule.rc_transfer_unapproved_record.should == record
    end
    
    it "onupdate: should remove rc_transfer_unapproved_record if the approval_status changed from 'U' to 'A' (approval)" do
      rc_transfer_schedule = Factory(:rc_transfer_schedule)
      rc_transfer_schedule.reload
      rc_transfer_schedule.rc_transfer_unapproved_record.should_not be_nil
      # the approval process changes the approval_status from U to A for a newly edited record
      rc_transfer_schedule.approval_status = 'A'
      rc_transfer_schedule.save
      rc_transfer_schedule.reload
      rc_transfer_schedule.rc_transfer_unapproved_record.should be_nil
    end
    
    it "ondestroy: should remove sm_unapproved_record if the record with approval_status 'U' was destroyed (approval) " do
      rc_transfer_schedule = Factory(:rc_transfer_schedule)
      rc_transfer_schedule.reload
      rc_transfer_schedule.rc_transfer_unapproved_record.should_not be_nil
      record = rc_transfer_schedule.rc_transfer_unapproved_record
      # the approval process destroys the U record, for an edited record 
      rc_transfer_schedule.destroy
      RcTransferUnapprovedRecord.find_by_id(record.id).should be_nil
    end
  end

  context "approve" do 
    it "should approve unapproved_record" do 
      rc_transfer_schedule = Factory(:rc_transfer_schedule, :approval_status => 'U')
      rc_transfer_schedule.approve.should == ""
      rc_transfer_schedule.approval_status.should == 'A'
    end

    it "should return error when trying to approve unmatched version" do 
      rc_transfer_schedule = Factory(:rc_transfer_schedule, :approval_status => 'A')
      rc_transfer_schedule1 = Factory(:rc_transfer_schedule, :approval_status => 'U', :approved_id => rc_transfer_schedule.id, :approved_version => 6)
      rc_transfer_schedule1.approve.should == "The record version is different from that of the approved version" 
    end
  end

  context "enable_approve_button?" do 
    it "should return true if approval_status is 'U' else false" do 
      rc_transfer_schedule1 = Factory(:rc_transfer_schedule, :approval_status => 'A')
      rc_transfer_schedule2 = Factory(:rc_transfer_schedule, :approval_status => 'U')
      rc_transfer_schedule1.enable_approve_button?.should == false
      rc_transfer_schedule2.enable_approve_button?.should == true
    end
  end
  
  context "udfs_should_be_correct" do
    it "should give error when the value is nil" do
      rc_transfer_schedule = Factory.build(:rc_transfer_schedule, udf1_name: 'udf1', udf1_type: 'text', udf1_value: nil, approval_status: 'A')
      rc_transfer_schedule.save.should == false
      rc_transfer_schedule.errors_on(:base).should == ["udf1 can't be blank"]
    end
    it "should give error when the type is date and value is not a valid date" do
      rc_transfer_schedule = Factory.build(:rc_transfer_schedule, udf1_name: 'udf1', udf1_type: 'date', udf1_value: '2015-24-24', approval_status: 'A')
      rc_transfer_schedule.save.should == false
      rc_transfer_schedule.errors_on(:base).should == ["udf1 is not a date"]
    end
    it "should give error when the type is text and value is too long" do
      rc_transfer_schedule = Factory.build(:rc_transfer_schedule, udf1_name: 'udf1', udf1_type: 'text', udf1_value: '1232301293819028312uw1288127312318923012381923019231uw192u8319238120wi1293812312wi1290', approval_status: 'A')
      rc_transfer_schedule.save.should == false
      rc_transfer_schedule.errors_on(:base).should == ["udf1 is too long, maximum is 50 charactres"]
    end
    it "should give error when the type is text and value includes special characters" do
      rc_transfer_schedule = Factory.build(:rc_transfer_schedule, udf1_name: 'udf1', udf1_type: 'text', udf1_value: '!@123!@#', approval_status: 'A')
      rc_transfer_schedule.save.should == false
      rc_transfer_schedule.errors_on(:base).should == ["udf1 should not include special characters"]
    end
  end
  
  context "set_app_code" do
    it "should set the app_code" do
      rc_app = Factory(:rc_app, :app_id => 'APP000', :approval_status => 'A')
      rc_transfer_schedule = Factory(:rc_transfer_schedule, :approval_status => 'A', :rc_app_id => rc_app.id)
      rc_transfer_schedule.reload
      rc_transfer_schedule.app_code.should == 'APP000'
    end
  end
  
  context "sanitize_udfs" do
    it "should sanitize udfs" do
      rc_transfer_schedule = Factory(:rc_transfer_schedule, udf1_name: 'udf1', udf1_type: 'text', udf1_value: 'abc', udf1_name: nil, udf1_type: nil, udf1_value: nil, approval_status: 'A')
      rc_transfer_schedule.udf2_name.should be_nil
      rc_transfer_schedule.udf2_type.should be_nil
      rc_transfer_schedule.udf2_value.should be_nil
    end
  end
  
  context "retry_interval" do
    it "should validate the retry interval" do
      rc_transfer_schedule = Factory.build(:rc_transfer_schedule, retry_in_mins: 10, max_retries: 3, interval_in_mins: 20)
      rc_transfer_schedule.errors_on(:base).should == ["Total Retry Interval (Retry Interval * Max No. of Retries) should be less than Schedule Interval"]
      
      rc_transfer_schedule = Factory.build(:rc_transfer_schedule, retry_in_mins: 10, max_retries: 3, interval_in_mins: 50)
      rc_transfer_schedule.errors_on(:base).should == []
    end
  end
  
  context "value_of_acct_threshold_amt" do
    it "should validate acct_threshold_amt" do
      rc_transfer_schedule = Factory.build(:rc_transfer_schedule, acct_threshold_amt: 100.99999)
      rc_transfer_schedule.errors_on(:acct_threshold_amt).should == ["is invalid, only two digits are allowed after decimal point"]
      
      rc_transfer_schedule = Factory.build(:rc_transfer_schedule, acct_threshold_amt: 100.99)
      rc_transfer_schedule.errors_on(:acct_threshold_amt).should == []

      rc_transfer_schedule = Factory.build(:rc_transfer_schedule, acct_threshold_amt: 100)
      rc_transfer_schedule.errors_on(:acct_threshold_amt).should == []
    end
  end
  
  context "set_interval_in_mins" do
    it "should set interval_in_mins if interval_kind = Days" do
      rc_transfer_schedule = Factory(:rc_transfer_schedule, interval_unit: 'Days', interval_in_mins: 2)
      rc_transfer_schedule.reload
      rc_transfer_schedule.interval_in_mins.should == 2880
      
      rc_transfer_schedule = Factory(:rc_transfer_schedule, interval_unit: 'Minutes', interval_in_mins: 30)
      rc_transfer_schedule.reload
      rc_transfer_schedule.interval_in_mins.should == 30
    end
  end
end