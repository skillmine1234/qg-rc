module RcTransfersHelper
  def find_logs(params,record)
    if params[:step_name] != 'ALL'
      record.rc_audit_steps.where('step_name=?',params[:step_name]).order("attempt_no desc") rescue []
    else
      record.rc_audit_steps.order("id desc") rescue []
    end      
  end

  def allow_retry(record)
    if (record.max_retries > 0 && ((record.attempt_no % record.max_retries) == 0) && (record.batch_no == record.rc_transfer_schedule.try(:last_batch_no)) && (['CREDIT FAILED','BALINQ FAILED'].include?(record.status_code)))
      true
    else
      false
    end
  end
end
