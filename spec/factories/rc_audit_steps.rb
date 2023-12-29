FactoryGirl.define do
  factory :rc_audit_step do
    rc_auditable_id 1
    rc_auditable_type "RcTransfer"
    step_no 1
    attempt_no 1
    status_code "NEW"
    step_name "NEW"
  end
end