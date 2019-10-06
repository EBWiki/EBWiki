# frozen_string_literal: true

namespace :users do
  desc 'mark all users as confirmed'
  task confirm_all: :environment do
    p 'Start confirming users'
    User.all.in_batches do |group|
      group.update_all(confirmed_at: Time.now)
    end
    p 'All users are confirmed'
  end 
end