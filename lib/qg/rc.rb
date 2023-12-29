require "qg/rc/engine"
module Qg
  module Rc
    NAME = 'Recurring Transfer'
    GROUP = 'recurring-transfer'
    MENU_ITEMS = [:rc_app, :rc_transfer_schedule, :rc_transfer]
    MODELS = ['RcTransferUnapprovedRecord','RcTransfer','RcTransferSchedule','RcAuditStep','RcApp']
    TEST_MENU_ITEMS = []
  end
end
