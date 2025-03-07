require 'faker'

USER_COUNT = 100_000
RELATIONSHIPS_PER_USER = 50..200
SLEEP_RECORDS_PER_USER = 5..30
BATCH_SIZE = 10_000

puts "Seeding users..."
USER_COUNT.times.each_slice(BATCH_SIZE) do |batch|
  users = batch.map { { name: Faker::Name.name, created_at: Time.now, updated_at: Time.now } }
  User.insert_all(users)
  puts "#{users.size} users created (Total: #{User.count})"
end
puts "Users seeded!"

puts "Seeding relationships..."
User.find_each(batch_size: BATCH_SIZE) do |user|
  followed_ids = User.where.not(id: user.id).order("RAND()").limit(rand(RELATIONSHIPS_PER_USER)).pluck(:id)
  relationships = followed_ids.map do |followed_id|
    { follower_id: user.id, followed_user_id: followed_id, created_at: Time.now, updated_at: Time.now }
  end
  Relationship.insert_all(relationships) unless relationships.empty?
end
puts "Relationships seeded!"

puts "Seeding sleep records..."
User.find_each(batch_size: BATCH_SIZE) do |user|
  sleep_records = []
  rand(SLEEP_RECORDS_PER_USER).times do
    sleep_at = Faker::Time.backward(days: 30, period: :night)
    wake_up_at = sleep_at + rand(6..10).hours
    sleep_records << {
      user_id: user.id,
      sleep_at: sleep_at,
      wake_up_at: wake_up_at,
      duration: (wake_up_at - sleep_at).to_i,
      created_at: Time.now,
      updated_at: Time.now
    }
  end
  SleepRecord.insert_all(sleep_records) unless sleep_records.empty?
end
puts "Sleep records seeded!"
