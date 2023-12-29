# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :rc_app do
    sequence(:app_id) {|n| "%03i" % "#{n}"}
    udf1_name 'udf1'
    udf1_type 'number'
    url 'http://localhost'
    approval_status "U"
    last_action "C"
    lock_version 1
    approved_version 1
  end
end