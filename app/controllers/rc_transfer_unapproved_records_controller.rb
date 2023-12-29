require 'will_paginate/array'

class RcTransferUnapprovedRecordsController < ApplicationController
  #authorize_resource
  before_action :authenticate_user!
  before_action :block_inactive_user!
  respond_to :json
  include ApplicationHelper
  include RcTransferUnapprovedRecordsHelper

  def index
    records = filter_records(RcTransferUnapprovedRecord)
    @records = records.paginate(:per_page => 10, :page => params[:page]) rescue []
  end
end
