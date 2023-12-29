class RcApp < ActiveRecord::Base
  include Approval
  include RcTransferApproval
  
  TOTAL_SETTINGS_COUNT = 5
  include Setting

  enum udf_types: [:number, :date, :text]
  belongs_to :created_user, :foreign_key =>'created_by', :class_name => 'User'
  belongs_to :updated_user, :foreign_key =>'updated_by', :class_name => 'User'
  
  store :udf1, accessors: [:udf1_name, :udf1_type], coder: JSON
  store :udf2, accessors: [:udf2_name, :udf2_type], coder: JSON
  store :udf3, accessors: [:udf3_name, :udf3_type], coder: JSON
  store :udf4, accessors: [:udf4_name, :udf4_type], coder: JSON
  store :udf5, accessors: [:udf5_name, :udf5_type], coder: JSON

  validates_presence_of :app_id, :url
  
  validates_uniqueness_of :app_id, :scope => :approval_status
  
  validates_presence_of :udf1_name, unless: "udf2_name.blank?", message: "can't be blank when Udf2 name is present"
  validates_presence_of :udf2_name, unless: "udf3_name.blank?", message: "can't be blank when Udf3 name is present"
  validates_presence_of :udf3_name, unless: "udf4_name.blank?", message: "can't be blank when Udf4 name is present"
  validates_presence_of :udf4_name, unless: "udf5_name.blank?", message: "can't be blank when Udf5 name is present"
  
  before_save :set_udf_cnts
  validate :password_should_be_present
  
  before_save :encrypt_password
  after_save :decrypt_password
  after_find :decrypt_password
  
  private

  def set_udf_cnts
    self.udfs_cnt = 0
    self.udfs_cnt += 1 unless udf1_name.blank?
    self.udfs_cnt += 1 unless udf2_name.blank?
    self.udfs_cnt += 1 unless udf3_name.blank?
    self.udfs_cnt += 1 unless udf4_name.blank?
    self.udfs_cnt += 1 unless udf5_name.blank?
  end
  
  def decrypt_password
    self.http_password = DecPassGenerator.new(http_password,ENV['CONSUMER_KEY'], ENV['CONSUMER_SECRET']).generate_decrypted_data if http_password.present?
  end
  
  def encrypt_password
    self.http_password = EncPassGenerator.new(self.http_password, ENV['CONSUMER_KEY'], ENV['CONSUMER_SECRET']).generate_encrypted_password unless http_password.to_s.empty?
  end

  def password_should_be_present
    errors[:base] << "HTTP Password can't be blank if HTTP Username is present" if self.http_username.present? and (self.http_password.blank? or self.http_password.nil?)
  end
end