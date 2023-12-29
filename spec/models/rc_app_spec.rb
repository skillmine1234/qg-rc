require 'spec_helper'

describe RcApp do
  context "associations" do
    it { should belong_to(:created_user) }
    it { should belong_to(:updated_user) }
  end
  
  context "encrypt_password" do 
    it "should encrypt the http_password" do
      rc_app = Factory.build(:rc_app, http_username: 'username', http_password: 'password')
      rc_app.save.should be_true
      rc_app.reload
      rc_app.http_password.should == "password"
    end
    it "should encrypt the settings with type password" do 
      rc_app = Factory.build(:rc_app, setting1_name: 'name1', setting1_type: 'text', setting1_value: 'value1', setting2_name: 'name2', setting2_type: 'password', setting2_value: 'password123')
      rc_app.save.should be_true
      rc_app.reload
      rc_app.setting2_value.should == "password123"
    end
  end
  
  context "decrypt_password" do 
    it "should decrypt the http_password" do 
      rc_app = Factory(:rc_app, http_username: 'username', http_password: 'password')
      rc_app.http_password.should == "password"
    end
    it "should decrypt the settings with type password" do 
      rc_app = Factory.build(:rc_app, setting1_name: 'name1', setting1_type: 'text', setting1_value: 'value1', setting2_name: 'name2', setting2_type: 'password', setting2_value: 'password123')
      rc_app.setting2_value.should == "password123"
    end
  end

  context "validation" do
    [:app_id, :url].each do |att|
      it { should validate_presence_of(att) }
    end
    it "should validate presence of http_password if http_username is present" do
      rc_app = Factory.build(:rc_app, http_username: 'username', http_password: nil)
      rc_app.save.should == false
      rc_app.errors[:base].should == ["HTTP Password can't be blank if HTTP Username is present"]
    end
  end

  context "rc_transfer_unapproved_records" do 
    it "onupdate: should not remove rc_transfer_unapproved_record if approval_status did not change from U to A" do
      rc_app = Factory(:rc_app)
      rc_app.reload
      rc_app.rc_transfer_unapproved_record.should_not be_nil
      record = rc_app.rc_transfer_unapproved_record
      # we are editing the U record, before it is approved
      rc_app.url = 'http://localhost'
      rc_app.save
      rc_app.reload
      rc_app.rc_transfer_unapproved_record.should == record
    end
    
    it "onupdate: should remove rc_transfer_unapproved_record if the approval_status changed from 'U' to 'A' (approval)" do
      rc_app = Factory(:rc_app)
      rc_app.reload
      rc_app.rc_transfer_unapproved_record.should_not be_nil
      # the approval process changes the approval_status from U to A for a newly edited record
      rc_app.approval_status = 'A'
      rc_app.save
      rc_app.reload
      rc_app.rc_transfer_unapproved_record.should be_nil
    end
    
    it "ondestroy: should remove sm_unapproved_record if the record with approval_status 'U' was destroyed (approval) " do
      rc_app = Factory(:rc_app)
      rc_app.reload
      rc_app.rc_transfer_unapproved_record.should_not be_nil
      record = rc_app.rc_transfer_unapproved_record
      # the approval process destroys the U record, for an edited record 
      rc_app.destroy
      RcTransferUnapprovedRecord.find_by_id(record.id).should be_nil
    end
  end

  context "approve" do 
    it "should approve unapproved_record" do 
      rc_app = Factory(:rc_app, :approval_status => 'U')
      rc_app.approve.should == ""
      rc_app.approval_status.should == 'A'
    end

    it "should return error when trying to approve unmatched version" do 
      rc_app = Factory(:rc_app, :approval_status => 'A')
      rc_app1 = Factory(:rc_app, :approval_status => 'U', :approved_id => rc_app.id, :approved_version => 6)
      rc_app1.approve.should == "The record version is different from that of the approved version" 
    end
  end

  context "enable_approve_button?" do 
    it "should return true if approval_status is 'U' else false" do 
      rc_app1 = Factory(:rc_app, :approval_status => 'A')
      rc_app2 = Factory(:rc_app, :approval_status => 'U')
      rc_app1.enable_approve_button?.should == false
      rc_app2.enable_approve_button?.should == true
    end
  end
  
  context "set_cnts" do
    it "should set counts of udfs and settings" do
      rc_app = Factory(:rc_app, udf1_name: 'udf1', udf1_type: 'number', udf2_name: 'udf2', udf2_type: 'date', setting1_name: 'set1', setting1_type: 'number', setting1_value: "1")
      rc_app.udfs_cnt.should == 2
      rc_app.settings_cnt.should == 1
    end
  end
  
  context "default_scope" do 
    it "should only return 'A' records by default" do 
      rc_app1 = Factory(:rc_app, :approval_status => 'A') 
      rc_app2 = Factory(:rc_app, :url => 'http://localhost')
      RcApp.all.should == [rc_app1]
      rc_app2.approval_status = 'A'
      rc_app2.save
      RcApp.all.should == [rc_app1,rc_app2]
    end
  end  
end
