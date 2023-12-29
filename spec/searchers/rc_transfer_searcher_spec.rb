require 'spec_helper'

describe RcTransferSearcher do
  context 'searcher' do
    it 'should return rc_transfer' do
      rc_transfers = [Factory(:rc_transfer, txn_kind: 'BALINQ', status_code: 'BALINQ FAILED')]
      rc_transfers << Factory(:rc_transfer, txn_kind: 'BALINQ', status_code: 'SKIP CREDIT:NO BALANCE')
      rc_transfers << Factory(:rc_transfer, txn_kind: 'FT')
      RcTransferSearcher.new({:remove_default => nil}).paginate.should == [rc_transfers[2]]
      RcTransferSearcher.new({:remove_default => 'Y', status_code: 'BALINQ FAILED'}).paginate.should == [rc_transfers[0]]
      RcTransferSearcher.new({:remove_default => 'Y'}).paginate.should == rc_transfers.reverse

      rc_transfer = Factory(:rc_transfer, :rc_transfer_code => '123')
      RcTransferSearcher.new({rc_transfer_code: '123'}).paginate.should == [rc_transfer]
      RcTransferSearcher.new({rc_transfer_code: '1230'}).paginate.should == []

      rc_transfer = Factory(:rc_transfer, :bene_account_no => '1234')
      RcTransferSearcher.new({bene_account_no: '1234'}).paginate.should == [rc_transfer]
      RcTransferSearcher.new({bene_account_no: '12345'}).paginate.should == []

      rc_transfer = Factory(:rc_transfer, :debit_account_no => "2332433423434234234")
      RcTransferSearcher.new({:debit_account_no => "2332433423434234234"}).paginate.should == [rc_transfer]
      RcTransferSearcher.new({:debit_account_no => "123123131231313212"}).paginate.should == []

      rc_transfer = Factory(:rc_transfer, :transfer_rep_ref => "QW12345")
      RcTransferSearcher.new({:transfer_rep_ref => "QW12345"}).paginate.should == [rc_transfer]
      RcTransferSearcher.new({:transfer_rep_ref => "QAQWSWQ"}).paginate.should == []

      rc_transfers = [Factory(:rc_transfer, :transfer_amount => 300)]
      rc_transfers << Factory(:rc_transfer, :transfer_amount => 400)
      RcTransferSearcher.new({from_transfer_amount:  250, to_transfer_amount: 350 }).paginate.should == [rc_transfers[0]]
      RcTransferSearcher.new({from_transfer_amount:  250, to_transfer_amount: 600 }).paginate.should == rc_transfers.reverse

      rc_transfer = Factory(:rc_transfer, :status_code => 'NOTIFIED: OK')
      RcTransferSearcher.new({status_code: 'NOTIFIED: OK'}).paginate.should == [rc_transfer]
      RcTransferSearcher.new({status_code: 'NEW'}).paginate.should == []
      
      rc_transfer = Factory(:rc_transfer, :notify_status => 'STRING1')
      RcTransferSearcher.new({notify_status: 'STRING1'}).paginate.should == [rc_transfer]
      RcTransferSearcher.new({notify_status: 'STRING2'}).paginate.should == []
      
      rc_transfer = Factory(:rc_transfer, :mobile_no => '1234567890')
      RcTransferSearcher.new({mobile_no: '1234567890'}).paginate.should == [rc_transfer]
      RcTransferSearcher.new({mobile_no: '1234554321'}).paginate.should == []

      rc_transfer = Factory(:rc_transfer, :pending_approval => 'N')
      RcTransferSearcher.new({pending_approval: 'N'}).paginate.should == [rc_transfer]
      RcTransferSearcher.new({pending_approval: 'A'}).paginate.should == []

    end
  end
end
