class RcTransferScheduleSearcher < Searcher
  attr_searchable :page, :approval_status, :is_enabled, :code, :bene_account_no, :debit_account_no, :notify_mobile_no, :from_next_run_at, :to_next_run_at, :from_last_run_at, :to_last_run_at
  as_enum :is_enabled, [:Y, :N], map: :string, source: :is_enabled
  
  def find
    reln = RcTransferSchedule.unscoped.order('id desc')
    reln = reln.where("approval_status = ?", approval_status) if approval_status.present? 
    reln = reln.where("next_run_at >= ? and next_run_at <= ?", Time.zone.parse(from_next_run_at).beginning_of_day,Time.zone.parse(to_next_run_at).beginning_of_day) if from_next_run_at.present? and to_next_run_at.present?
    reln = reln.where("last_run_at >= ? and last_run_at <= ?", Time.zone.parse(from_last_run_at).beginning_of_day,Time.zone.parse(to_last_run_at).beginning_of_day) if from_last_run_at.present? and to_last_run_at.present?
    reln
  end
  
end