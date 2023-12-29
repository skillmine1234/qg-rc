class RcAuditStep < ActiveRecord::Base  
  belongs_to :rc_auditable, :polymorphic => true
end
