class RcTransferUnapprovedRecord < ActiveRecord::Base
  belongs_to :rc_transfer_approvable, :polymorphic => true, :unscoped => true
  RC_TABLES = ['RcTransferSchedule','RcApp']
end