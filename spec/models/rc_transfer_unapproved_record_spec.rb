require 'spec_helper'
describe RcTransferUnapprovedRecord do
  context 'association' do
    it { should belong_to(:rc_transfer_approvable) }
  end
end
