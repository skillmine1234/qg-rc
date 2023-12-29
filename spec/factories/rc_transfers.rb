# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :rc_transfer do
    rc_transfer_code '1234'
    batch_no 0
    status_code 'C'
    started_at '2015-04-20'
    debit_account_no '123456789'
    bene_account_no '9876543121'
    transfer_amount 100.0
    transfer_req_ref 'ABC1234'
    transfer_rep_ref 'QW12335'
    transferred_at '2015-04-20'
    notify_status 'C'
    notify_attempt_no 1
    notify_attempt_at '2015-04-20'
    notified_at '2015-04-20'
    notify_result 'C'
    customer_name 'Foo'
    customer_id '1234'
    mobile_no '9872536211'
    broker_uuid '1234'
    rc_app_id { Factory(:rc_app).id }
    txn_kind 'FT'
  end
end
