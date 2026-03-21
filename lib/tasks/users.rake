# frozen_string_literal: true

namespace :users do
  desc 'mark all users as confirmed'
  task confirm_all: :environment do
    p 'Start confirming users'
    User.where(confirmed_at: nil).in_batches do |group|
      # rubocop:disable Rails/SkipsModelValidations -- intentional bulk update, validations not needed
      group.update_all(confirmed_at: Time.current)
      # rubocop:enable Rails/SkipsModelValidations
    end
    p 'All users are confirmed'
  end
end
