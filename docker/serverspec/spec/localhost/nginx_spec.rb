require 'spec_helper'

describe 'nginx', if: ENV['ROLE'] == 'web' do
  describe service('nginx') do
    it { is_expected.to be_enabled }
    it { is_expected.to be_running }
    it { is_expected.to be_running.under('supervisor') }
  end

  describe port(80) do
    it { is_expected.to be_listening }
  end

  describe port(443) do
    it { is_expected.not_to be_listening }
  end

  describe command('curl -I http://localhost') do
    its(:stdout) { is_expected.to contain 'HTTP/1.1 200 OK' }
  end
end
