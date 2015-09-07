require 'spec_helper'

describe command('/usr/bin/ruby -e "print RUBY_VERSION"') do
  its(:stdout) { is_expected.to eq '2.2.3' }
  its(:exit_status) { is_expected.to eq 0 }
end

describe command('bundle --version') do
  its(:stdout) { is_expected.to eq "Bundler version 1.10.6\n" }
  its(:exit_status) { is_expected.to eq 0 }
end
