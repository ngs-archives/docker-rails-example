require 'spec_helper'

describe file('/etc/default/locale') do
  it { is_expected.to be_file }
  it { is_expected.to be_mode 755 }
  its(:content) { is_expected.to eq "LANG=\"en_US.UTF-8\"\n" }
end
