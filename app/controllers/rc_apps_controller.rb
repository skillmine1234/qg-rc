class RcAppsController < ApplicationController
  #authorize_resource
  before_action :authenticate_user!
  before_action :block_inactive_user!
  respond_to :json
  include ApplicationHelper

  def create
    @rc_app = RcApp.new(params[:rc_app])
    if !@rc_app.valid?
      render "edit"
    else
      @rc_app.created_by = current_user.id
      @rc_app.save!
      flash[:alert] = 'Rc App successfully created and is pending for approval'
      redirect_to @rc_app
    end
  end
  
  def edit
    rc_app = RcApp.unscoped.find_by_id(params[:id])
    if rc_app.approval_status == 'A' && rc_app.unapproved_record.nil?
      params = (rc_app.attributes).merge({:approved_id => rc_app.id,:approved_version => rc_app.lock_version, :app_id => rc_app.app_id})
      rc_app = RcApp.new(params)
    end
    @rc_app = rc_app
  end

  def update
    @rc_app = RcApp.unscoped.find_by_id(params[:id])
    @rc_app.attributes = params[:rc_app]
    if !@rc_app.valid?
      render "edit"
    else
      @rc_app.updated_by = current_user.id
      @rc_app.save!
      flash[:alert] = 'Rc App successfully modified successfully'
      redirect_to @rc_app
    end
    rescue ActiveRecord::StaleObjectError
      @rc_app.reload
      flash[:alert] = 'Someone edited the rc_app the same time you did. Please re-apply your changes to the rc_app.'
      render "edit"
  end 

  def show
    @rc_app = RcApp.unscoped.find_by_id(params[:id])
    respond_to do |format|
      format.json { render json: @rc_app }
      format.html 
    end 
  end

  def index
    rc_apps = (params[:approval_status].present? and params[:approval_status] == 'U') ? RcApp.unscoped.where("approval_status =?",'U').order("id desc") : RcApp.order("id desc")
    @rc_apps_count = rc_apps.count
    @rc_apps = rc_apps.paginate(:per_page => 10, :page => params[:page]) rescue []
  end
  
  def audit_logs
    @rc_app = RcApp.unscoped.find(params[:id]) rescue nil
    @audit = @rc_app.audits[params[:version_id].to_i] rescue nil
  end
  
  def approve
    @rc_app = RcApp.unscoped.find(params[:id]) rescue nil
    RcApp.transaction do
      approval = @rc_app.approve
      if approval.empty?
        flash[:alert] = "Rc App record was approved successfully"
      else
        msg = @rc_app.errors.full_messages << approval
        flash[:alert] = msg
        raise ActiveRecord::Rollback
      end
    end
    redirect_to @rc_app
  end

  private

  def rc_app_params
    params.require(:rc_app).permit(:lock_version, :last_action, :updated_by, :url, :http_username, :http_password, :settings_cnt, :udfs_cnt,
    :udf1_name, :udf1_type,
    :udf2_name, :udf2_type,
    :udf3_name, :udf3_type,
    :udf4_name, :udf4_type,
    :udf5_name, :udf5_type,
    :setting1_name, :setting1_type, :setting1_value, 
    :setting2_name, :setting2_type, :setting2_value, 
    :setting3_name, :setting3_type, :setting3_value, 
    :setting4_name, :setting4_type, :setting4_value,
    :setting5_name, :setting5_type, :setting5_value,
    :app_id, :approval_status, :approved_version, :approved_id)
  end
end
