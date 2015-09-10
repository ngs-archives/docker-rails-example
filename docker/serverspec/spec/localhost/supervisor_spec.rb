require 'spec_helper'

describe file('/var/run/supervisor.sock') do
  it { is_expected.to be_socket }
end
