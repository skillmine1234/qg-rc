# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :rc_transfer_unapproved_record do
    rc_transfer_approvable_id 1
    rc_transfer_approvable_type "MyString"
  end
end
