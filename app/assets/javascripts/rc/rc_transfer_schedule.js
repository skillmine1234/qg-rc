$(document).ready(function(){
  
  function get_rc_app(id) {
    $.ajax({
       url: "/rc_transfer_schedules/udfs/"+id,
       dataType: "script"
    });
  }

  $('#rc_transfer_schedule_rc_app_id').on('change',function(){
    get_rc_app($('#rc_transfer_schedule_rc_app_id').val());
  });

  $('#rc_transfer_schedule_txn_kind').on('change',function(){
    if ($(this).val() == 'BALINQ') {
      $('#rc_transfer_schedule_bene_account_no').val('');
      $('#rc_transfer_schedule_bene_account_no').prop('readOnly',true);
      $('#rc_transfer_schedule_bene_account_ifsc').val('');
      $('#rc_transfer_schedule_bene_account_ifsc').prop('readOnly',true);
      $('#rc_transfer_schedule_bene_name').val('');
      $('#rc_transfer_schedule_bene_name').prop('readOnly',true);
      $('#rc_transfer_schedule_acct_threshold_amt').val('');
      $('#rc_transfer_schedule_acct_threshold_amt').prop('readOnly',true);
    }
    else if ($(this).val() == 'COLLECT') {
      $('#rc_transfer_schedule_bene_account_ifsc').val('');
      $('#rc_transfer_schedule_bene_account_ifsc').prop('readOnly',true);
      $('#rc_transfer_schedule_bene_name').val('');
      $('#rc_transfer_schedule_bene_name').prop('readOnly',true);
      $('#rc_transfer_schedule_bene_account_no').prop('readOnly',false);
      $('#rc_transfer_schedule_acct_threshold_amt').prop('readOnly',false);
    }
    else {
      $('#rc_transfer_schedule_bene_account_no').prop('readOnly',false);
      $('#rc_transfer_schedule_bene_account_ifsc').prop('readOnly',false);
      $('#rc_transfer_schedule_bene_name').prop('readOnly',false);
      $('#rc_transfer_schedule_acct_threshold_amt').prop('readOnly',false);
    }
  });

  if ($('#rc_transfer_schedule_txn_kind').val() == 'BALINQ') {
    $('#rc_transfer_schedule_bene_account_no').val('');
    $('#rc_transfer_schedule_bene_account_no').prop('readOnly',true);
    $('#rc_transfer_schedule_bene_account_ifsc').val('');
    $('#rc_transfer_schedule_bene_account_ifsc').prop('readOnly',true);
    $('#rc_transfer_schedule_bene_name').val('');
    $('#rc_transfer_schedule_bene_name').prop('readOnly',true);
    $('#rc_transfer_schedule_acct_threshold_amt').val('');
    $('#rc_transfer_schedule_acct_threshold_amt').prop('readOnly',true);
  }
  if ($('#rc_transfer_schedule_txn_kind').val() == 'COLLECT') {
    $('#rc_transfer_schedule_bene_account_ifsc').val('');
    $('#rc_transfer_schedule_bene_account_ifsc').prop('readOnly',true);
    $('#rc_transfer_schedule_bene_name').val('');
    $('#rc_transfer_schedule_bene_name').prop('readOnly',true);
  }
});