RcApp.seed_once(:app_id) do |s|
  s.id = 10000
  s.app_id = 'VODAFONE'
  s.url = 'http://182.19.20.182:81/mcommerce.webservices/pgService'
  s.setting1_name  = 'username'
  s.setting1_type  = 'text'
  s.setting1_value = '2UyVFO+gxMM1veAt7Ehzgw=='
  s.setting2_name  = 'password'
  s.setting2_type  = 'text'
  s.setting2_value = 'z5xVCbkuR6EsM4W/BU3CNg=='
  s.created_by = 'Q'
  s.approval_status = 'A'
end

RcApp.seed_once(:app_id) do |s|
  s.id = 10001
  s.app_id = 'RELIANCE'
  s.url = 'https://ecollection.ril.com/BankPymtWS/service.asmx'
  s.http_username = 'BkPymtUsr'
  s.http_password = 'ecol@12345'
  s.udf1_name  = 'beneficiary_identification_code'
  s.udf1_type  = 'text'
  s.udf2_name  = 'remitter_identification_code'
  s.udf2_type  = 'text'
  s.created_by = 'Q'
  s.approval_status = 'A'
end

RcApp.seed_once(:app_id) do |s|
  s.id = 10002
  s.app_id = 'TATAPOWER'
  s.url = 'https://www.tatapower-ddl.com/h2hlinkagetest/Service.asmx'
  s.udf1_name  = 'account_desc'
  s.udf1_type  = 'text'
  s.setting1_name = 'secure_string'
  s.setting1_type = 'text'
  s.setting1_value = 'H2HYESBANK'
  s.setting2_name = 'password'
  s.setting2_type = 'text'
  s.setting2_value = 'yesbank@12345'
  s.created_by = 'Q'
  s.approval_status = 'A'
end

RcApp.seed_once(:app_id) do |s|
  s.id = 10003
  s.app_id = 'IMCL'
  s.url = 'https://lcoportal.mobiotics.com/admin/v1/bankpayment?'
  s.udf1_name = 'fr_code'
  s.udf1_type  = 'text'
  s.setting1_name = 'key'
  s.setting1_type = 'text'
  s.setting1_value = 'ytxQz6HJQgHv7Eei'
  s.created_by = 'Q'
  s.approval_status = 'A'
end