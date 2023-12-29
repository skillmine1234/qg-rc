class RcTransferSchedule < ActiveRecord::Base  
  include Approval
  include RcTransferApproval

  TXN_KINDS = %w(FT BALINQ COLLECT)
  INTERVAL_UNITS = %w(Minutes Days)
  self.table_name = "rc_transfer_schedule"
  
  store :udf1, accessors: [:udf1_name, :udf1_type, :udf1_value], coder: JSON
  store :udf2, accessors: [:udf2_name, :udf2_type, :udf2_value], coder: JSON
  store :udf3, accessors: [:udf3_name, :udf3_type, :udf3_value], coder: JSON
  store :udf4, accessors: [:udf4_name, :udf4_type, :udf4_value], coder: JSON
  store :udf5, accessors: [:udf5_name, :udf5_type, :udf5_value], coder: JSON

  belongs_to :created_user, :foreign_key =>'created_by', :class_name => 'User'
  belongs_to :updated_user, :foreign_key =>'updated_by', :class_name => 'User'
  belongs_to :rc_transfer, :foreign_key => 'code', :primary_key => 'rc_transfer_code'
  belongs_to :rc_app

  attr_accessor :interval_unit
  
  before_validation :set_interval_in_mins, if: "interval_unit=='Days'"

  validates_presence_of :code, :debit_account_no, :is_enabled, :max_retries, :retry_in_mins
  validates_presence_of :bene_account_no, :acct_threshold_amt, :bene_account_ifsc, :bene_name, if: "txn_kind=='FT'", message: "can't be blank when Transaction Kind is FT"
  validates :bene_account_ifsc, format: {with: /\A[A-Z|a-z]{4}[0][A-Za-z0-9]{6}+\z/, message: "Invalid format, expected format is : {[A-Z|a-z]{4}[0][A-Za-z0-9]{6}}" }, allow_blank: true

  validates :code, format: {with: /\A[a-z|A-Z|0-9]+\z/, :message => 'Invalid format, expected format is : {[a-z|A-Z|0-9]}' }, length: {maximum: 20}
  validates :debit_account_no, format: {with: /\A[0-9]+\z/, :message => 'Invalid format, expected format is : {[0-9]}' }, length: {minimum: 15, maximum: 20}
  validates :bene_account_no, format: {with: /\A[0-9]+\z/, :message => 'Invalid format, expected format is : {[0-9]}' }, length: {minimum: 1, maximum: 20}, allow_blank: true
  validates :notify_mobile_no, :numericality => {:only_integer => true}, length: {minimum: 10, maximum: 10}, allow_blank: true

  validates_uniqueness_of :code, :scope => :approval_status
  
  before_save :set_app_code
  before_validation :sanitize_udfs, unless: Proc.new { |c| c.rc_app.nil? }
  validate :udfs_should_be_correct, unless: Proc.new { |c| c.rc_app.nil? }
  validate :validate_next_run_at
  validates :interval_in_mins, :retry_in_mins, :max_retries, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }
  validates :retry_in_mins, :numericality => { :greater_than_or_equal_to => 15 }, if: "max_retries.present? && max_retries > 0"
  validate :retry_interval, unless: "retry_in_mins.nil? || max_retries.nil? || interval_in_mins.nil?"
  validates_length_of :bene_name, maximum: 25, allow_blank: true
  validate :value_of_acct_threshold_amt
  
  validates_absence_of :bene_name, if: "txn_kind=='COLLECT'", message: 'must be blank when Transaction Kind is COLLECT'
  validates_absence_of :bene_account_ifsc, if: "txn_kind=='COLLECT'", message: 'must be blank when Transaction Kind is COLLECT'

  def validate_next_run_at
    errors.add(:next_run_at,"should not be less than today's date") if !next_run_at.nil? and next_run_at < Time.zone.today.beginning_of_day
  end

  def next_run_at_value
    next_run_at.nil? ? Time.zone.now.try(:strftime, "%d/%m/%Y %I:%M%p") : next_run_at.try(:strftime, "%d/%m/%Y %I:%M%p")
  end

  private

  def set_interval_in_mins
    self.interval_in_mins = self.interval_in_mins * 1440
  end
  
  def set_app_code
     self.app_code = self.try(:rc_app).try(:app_id) if rc_app_id_changed?
   end
  
  def sanitize_udfs
    (self.udf5_name = nil; self.udf5_type = nil; self.udf5_value = nil) if rc_app.udfs_cnt < 5
    (self.udf4_name = nil; self.udf4_type = nil; self.udf4_value = nil) if rc_app.udfs_cnt < 4
    (self.udf3_name = nil; self.udf3_type = nil; self.udf3_value = nil) if rc_app.udfs_cnt < 3
    (self.udf2_name = nil; self.udf2_type = nil; self.udf2_value = nil) if rc_app.udfs_cnt < 2
    (self.udf1_name = nil; self.udf1_type = nil; self.udf1_value = nil) if rc_app.udfs_cnt < 1
  end
  
  def udfs_should_be_correct
    validate_udf(1, udf1_name, udf1_type, udf1_value)
    validate_udf(2, udf2_name, udf2_type, udf2_value)
    validate_udf(3, udf3_name, udf3_type, udf3_value)
    validate_udf(4, udf4_name, udf4_type, udf4_value)
    validate_udf(5, udf5_name, udf5_type, udf5_value)
  end

  def validate_udf(i, udf_name, udf_type, udf_value)
    
    if i < rc_app.udfs_cnt
      # udf should be as per template      
      if rc_app.send("udf#{i}_name") != udf_name || rc_app.send("udf#{i}_type") != udf_type
        errors[:base] << "Tampered Request: udf#{i} is not as per definition #{udf_name}:#{udf_type}:#{rc_app.udfs_cnt}" 
        return
      end
    end
    
    # udf name/type is as per defintion, now check for the value
    errors[:base] << "#{udf_name} can't be blank" if udf_name.present? and (udf_value.nil? or udf_value.blank?)
    DateTime.parse udf_value rescue errors[:base] << "#{udf_name} is not a date" if udf_type == "date"
    errors[:base] << "#{udf_name} is too long, maximum is 50 charactres" if udf_type == "text" and udf_value.present? and udf_value.length > 50
    errors[:base] << "#{udf_name} should not include special characters" if udf_type == "text" and udf_value.present? and (udf_value =~ /[A-Za-z0-9]+$/).nil?
  end
  
  def retry_interval
    errors[:base] << "Total Retry Interval (Retry Interval * Max No. of Retries) should be less than Schedule Interval" if ((retry_in_mins * max_retries) > interval_in_mins)
  end

  def value_of_acct_threshold_amt
    errors.add(:acct_threshold_amt, "is invalid, only two digits are allowed after decimal point") if acct_threshold_amt.to_f != acct_threshold_amt.to_f.round(2)
  end
end
