require 'spec_helper'

describe 'sidekiq', if: ENV['ROLE'] == 'job' do
  describe service('sidekiq') do
    it { is_expected.not_to be_enabled }
    it { is_expected.to be_running }
    it { is_expected.to be_running.under('supervisor') }
  end

  # TODO: run on web server
  # describe command(%q{curl -XPOST -H 'Content-Type: application/json' -d '{"book":{"title":"Hoge", "author":"ngs"}}' http://localhost/books/create_delayed}) do
  #   its(:stdout) { is_expected.to contain 'HTTP/1.1 201 Created' }
  #   its(:stdout) { is_expected.to match /{"arguments":\[{"title":"Hoge","author":"ngs"}\],"job_id":"[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}","queue_name":"default"}/ }
  # end

  describe command(%q{cd $RAILS_ROOT && ./bin/rails runner -e production "p BooksJob.perform_later(author: 'ngs', title: 'Hoge')" 2>&1}) do
    its(:exit_status) { is_expected.to eq 0 }
    its(:stdout) { is_expected.to match /#<BooksJob:0x[0-9a-f]{14}/ }
  end

  describe file('/var/www/app/log/sidekiq.production.log') do
    it { is_expected.to be_file }
    its(:content) { is_expected.to contain 'Starting processing, hit Ctrl-C to stop' }
    its(:content) { is_expected.to contain 'INFO: start' }
    its(:content) { is_expected.to contain 'INFO: done' }
  end

  describe file('/var/www/app/log/production.log') do
    it { is_expected.to be_file }
    its(:content) { is_expected.to contain 'Performed BooksJob from Sidekiq' }
  end

  describe command(%q{cd $RAILS_ROOT && ./bin/rails runner "p Book.all.map{|b| [b.title, b.author] }" 2>&1}) do
    its(:exit_status) { is_expected.to eq 0 }
    its(:stdout) { is_expected.to eq %Q{[["Hoge", "ngs"]]\n} }
  end
end
