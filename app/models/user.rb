class User < ApplicationRecord
  has_many :sleep_records, dependent: :destroy

  has_many :incoming_relationships, class_name: 'Relationship', foreign_key: :follower_id, dependent: :destroy
  has_many :followers, through: :incoming_relationships, source: :follower

  has_many :outgoing_relationships, class_name: 'Relationship', foreign_key: :followed_user_id, dependent: :destroy
  has_many :following, through: :outgoing_relationships, source: :followed_user

  validates :name, presence: true
end
