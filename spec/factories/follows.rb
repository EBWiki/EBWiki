# frozen_string_literal: true

# This will guess the Article class
FactoryBot.define do
  factory :follow do |f|
    f.follower_id { 1 }
    f.followable_id { 1 }
    f.followable_type { 'Case' }
    f.follower_type { 'User' }
  end
end
