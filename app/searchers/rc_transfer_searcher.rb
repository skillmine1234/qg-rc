class RcTransferSearcher < Searcher
  attr_searchable :page, :remove_default, :rc_transfer_code, :bene_account_no, :debit_account_no, :transfer_rep_ref, :from_transfer_amount, :to_transfer_amount, :status_code, :notify_status, :mobile_no, :pending_approval
  as_enum :status_code, [:NEW, :FAILED, :'PENDING CREDIT', :COMPLETED, :'CREDIT FAILED', :'BALINQ FAILED', :'SENT_TO_BENEFICIARY'], map: :string, source: :status_code
  as_enum :notify_status, [:'PENDING NOTIFICATION', :'NOTIFIED:REJECTED', :'NOTIFIED:OK', :'NOTIFICATION FAILED'], map: :string, source: :notify_status
  
  def find
    reln = RcTransfer.order('id desc')
    reln = reln.where.not("status_code IN ('BALINQ FAILED','SKIP CREDIT:NO BALANCE')") if !(remove_default.present? && remove_default == 'Y')
    reln = reln.where("transfer_amount >= ? and transfer_amount <= ?", from_transfer_amount.to_f, to_transfer_amount.to_f) if from_transfer_amount.present? and to_transfer_amount.present?
    reln
  end
  
end