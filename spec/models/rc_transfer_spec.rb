require 'spec_helper'

describe RcTransfer do
  context 'association' do
    it { should have_one(:rc_transfer_schedule) }
    it { should have_many(:rc_audit_steps) }
  end
end
