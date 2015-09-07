require 'spec_helper'

describe 'unicorn', if: ENV['ROLE'] == 'web' do
  describe service('unicorn') do
    it { is_expected.not_to be_enabled }
    it { is_expected.to be_running }
    it { is_expected.to be_running.under('supervisor') }
  end

  describe file('/var/run/unicorn.sock') do
    it { is_expected.to be_socket }
  end
end
