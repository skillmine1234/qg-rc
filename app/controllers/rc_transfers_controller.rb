require 'will_paginate/array'
class RcTransfersController < ApplicationController
  #authorize_resource
  before_action :authenticate_user!
  before_action :block_inactive_user!
  respond_to :json
  include ApplicationHelper
  include RcTransfersHelper
  
  def index
    if request.get?
      @searcher = RcTransferSearcher.new(params.permit(:page))
    else
      @searcher = RcTransferSearcher.new(search_params)
    end
    @records = @searcher.paginate
  end
  
  def show
    @rc_transfer = RcTransfer.find_by_id(params[:id])
  end

  def audit_steps
    @record = RcTransfer.find(params[:id])
    record_values = find_logs(params, @record)
    @record_values_count = record_values.count(:id)
    @record_values = record_values.paginate(:per_page => 10, :page => params[:page]) rescue []
  end

  def update_multiple
    if params[:rc_transfer_ids]
      @rc_transfers = RcTransfer.find(params[:rc_transfer_ids])
      unless @rc_transfers.empty?
        @rc_transfers.each {|rc_transfer| rc_transfer.update_attributes(:pending_approval => "N", :notify_status => 'PENDING NOTIFICATION')}
        flash[:notice] = "Updated transactions!"
      end
    else
      flash[:notice] = "You haven't selected any transaction records!"
    end
    redirect_to :back
  end

  def update
    @rc_transfer = RcTransfer.find(params[:id])
    if @rc_transfer.update_attributes(:pending_approval => 'N', :notify_status => 'PENDING NOTIFICATION')
      flash[:notice] = "RC Transfer is sucessfully updated"
    else
      flash[:notice] = @rc_transfer.errors.full_messages
    end
    redirect_to :back
  end

  def retry
    rc_transfer = RcTransfer.find(params[:id])
    rc_transfer.retry
  rescue ::Fault::ProcedureFault, OCIError => e
   flash[:alert] = "#{e.message}"    
  ensure
   redirect_to rc_transfer
  end
  
  private    
    def search_params
      params.require(:rc_transfer_searcher).permit( :page, :remove_default, :rc_transfer_code, :bene_account_no, :debit_account_no, :transfer_rep_ref, :from_transfer_amount, :to_transfer_amount, :status_code, :notify_status, :mobile_no, :pending_approval)
    end
end
