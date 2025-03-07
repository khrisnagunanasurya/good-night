FactoryBot.define do
  factory :relationship do
    association :follower, factory: :user
    association :followed_user, factory: :user
  end
end
