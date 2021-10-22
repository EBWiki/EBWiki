FactoryBot.define do
  factory :rollout_history do
    rollout_name { "Name" }
    change_date { Date.current }
    change_description { "MyText" }
    author_name { "Auth Name" }
  end
end
