module RcTransferUnapprovedRecordsHelper
  def filter_records(records)
    result = []
    RcTransferUnapprovedRecord::RC_TABLES.each do |record|
      count = RcTransferUnapprovedRecord.where("rc_transfer_approvable_type =?", record).count 
      result << {:record_type => record, :record_count => count}
    end
    result
  end
end


