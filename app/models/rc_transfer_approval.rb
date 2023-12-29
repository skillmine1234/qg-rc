module RcTransferApproval  
  extend ActiveSupport::Concern
  included do
    has_one :rc_transfer_unapproved_record, :as => :rc_transfer_approvable

    after_create :on_create_create_rc_transfer_unapproved_record
    after_destroy :on_destory_remove_rc_transfer_unapproved_records
    after_update :on_update_remove_rc_transfer_unapproved_records
  end

  def on_create_create_rc_transfer_unapproved_record
    if approval_status == 'U'
      RcTransferUnapprovedRecord.create!(:rc_transfer_approvable => self)
    end
  end

  def on_destory_remove_rc_transfer_unapproved_records
    if approval_status == 'U'
      rc_transfer_unapproved_record.delete
    end
  end
  
  def on_update_remove_rc_transfer_unapproved_records
    if approval_status == 'A' and approval_status_was == 'U'
      rc_transfer_unapproved_record.delete
    end
  end 
  
end