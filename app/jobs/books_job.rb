class BooksJob < ActiveJob::Base
  queue_as :default

  def perform(params)
    Book.create!(params)
  end
end
