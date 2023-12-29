require 'spec_helper'

describe RcTransferScheduleSearcher do
  context 'searcher' do
    it 'should return rc_transfer_schedule' do
      rc_transfer_schedule = Factory(:rc_transfer_schedule, :approval_status => 'U')
      RcTransferScheduleSearcher.new({approval_status: 'U'}).paginate.should == [rc_transfer_schedule]
      RcTransferScheduleSearcher.new({approval_status: 'A'}).paginate.should == []
      
      rc_transfer_schedule = Factory(:rc_transfer_schedule, :is_enabled => 'Y', :approval_status => 'A')
      RcTransferScheduleSearcher.new({is_enabled: 'Y'}).paginate.should == [rc_transfer_schedule]
      RcTransferScheduleSearcher.new({is_enabled: 'N'}).paginate.should == []
      
      rc_transfer_schedule = Factory(:rc_transfer_schedule, :code => 'STRING1', :approval_status => 'A')
      RcTransferScheduleSearcher.new({code: 'STRING1'}).paginate.should == [rc_transfer_schedule]
      RcTransferScheduleSearcher.new({code: 'STRING2'}).paginate.should == []

      rc_transfer_schedule = Factory(:rc_transfer_schedule, :bene_account_no => '12312313', :approval_status => 'A')
      RcTransferScheduleSearcher.new({bene_account_no: '12312313'}).paginate.should == [rc_transfer_schedule]
      RcTransferScheduleSearcher.new({bene_account_no: '21312321'}).paginate.should == []

      rc_transfer_schedule = Factory(:rc_transfer_schedule, :debit_account_no => '12312321313232313', :approval_status => 'A')
      RcTransferScheduleSearcher.new({debit_account_no: '12312321313232313'}).paginate.should == [rc_transfer_schedule]
      RcTransferScheduleSearcher.new({debit_account_no: '213213123131232321'}).paginate.should == []

      rc_transfer_schedule = Factory(:rc_transfer_schedule, :notify_mobile_no => '9985776655', :approval_status => 'A')
      RcTransferScheduleSearcher.new({notify_mobile_no: '9985776655'}).paginate.should == [rc_transfer_schedule]
      RcTransferScheduleSearcher.new({notify_mobile_no: '9988776656'}).paginate.should == []

      rc_transfer_schedules = [Factory(:rc_transfer_schedule, :next_run_at => (Time.now + 2.days).to_s, :approval_status => 'A')]
      rc_transfer_schedules << Factory(:rc_transfer_schedule, :next_run_at => (Time.now + 4.days).to_s, :approval_status => 'A')
      RcTransferScheduleSearcher.new({from_next_run_at:  (Time.now + 1.day).to_s, to_next_run_at: (Time.now + 3.day).to_s }).paginate.should == [rc_transfer_schedules[0]]
      RcTransferScheduleSearcher.new({from_next_run_at:  (Time.now + 1.day).to_s, to_next_run_at: (Time.now + 5.day).to_s }).paginate.should == rc_transfer_schedules.reverse

      rc_transfer_schedules = [Factory(:rc_transfer_schedule, :last_run_at => "2016-11-20 16:56:33 +0530", :approval_status => 'A')]
      rc_transfer_schedules << Factory(:rc_transfer_schedule, :last_run_at => "2017-05-20 16:56:33 +0530", :approval_status => 'A')
      RcTransferScheduleSearcher.new({from_last_run_at:  "2016-10-20 16:56:33 +0530", to_last_run_at: "2017-04-20 16:56:33 +0530" }).paginate.should == [rc_transfer_schedules[0]]
      RcTransferScheduleSearcher.new({from_last_run_at:  "2016-10-20 16:56:33 +0530", to_last_run_at: "2018-01-20 16:56:33 +0530" }).paginate.should == rc_transfer_schedules.reverse

    end
  end
end
