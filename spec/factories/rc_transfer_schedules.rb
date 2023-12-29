# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :rc_transfer_schedule do
    sequence(:code) {|n| "%04i" % "#{n}"}
    debit_account_no "123456789877733"
    bene_account_no "123456789877734"
    last_run_at "2016-10-12 11:33:24"
    notify_mobile_no "9988776655"
    txn_kind "BALINQ"
    created_by {Factory(:user).id}
    updated_by {Factory(:user).id}
    lock_version 1
    approval_status "U"
    last_action "C"
    approved_version 1
    is_enabled "Y"
    rc_app_id { Factory(:rc_app, :approval_status => 'A').id }
  end
end
