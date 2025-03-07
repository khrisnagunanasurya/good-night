RSpec.describe SleepRecord::Feed, type: :service do
  let(:user) { create(:user) }
  let(:followed_user_1) { create(:user) }
  let(:followed_user_2) { create(:user) }

  before do
    create(:relationship, follower: user, followed_user: followed_user_1)
    create(:relationship, follower: user, followed_user: followed_user_2)
  end

  subject { described_class.call(user: user) }

  describe '#execute' do
    context 'when fetching sleep records successfully' do
      let!(:sleep_record_1) do
        create(:sleep_record, user: followed_user_1, sleep_at: 3.days.ago, wake_up_at: 1.5.days.ago)
      end
      let!(:sleep_record_2) do
        create(:sleep_record, user: followed_user_2, sleep_at: 2.days.ago, wake_up_at: 1.day.ago)
      end

      it 'is expected to return sleep records from followed users' do
        expect(subject.result).to include(sleep_record_1, sleep_record_2)
      end

      it 'is expected to return sleep records ordered by duration and created_at (Longer sleep first)' do
        expect(subject.result).to eq([sleep_record_1, sleep_record_2])
      end
    end

    context 'when user is invalid' do
      it 'is expected to return an error if user is nil' do
        service = described_class.call(user: nil)

        expect(service.success?).to be_falsey
        expect(service.error_message).to eq('Invalid user.')
      end

      it 'is expected to return an error if user is not persisted' do
        new_user = build(:user)
        service = described_class.call(user: new_user)

        expect(service.success?).to be_falsey
        expect(service.error_message).to eq('Invalid user.')
      end
    end

    context 'when followed users have no sleep records' do
      it 'is expected to return an empty array' do
        expect(subject.result).to eq([])
      end
    end

    context 'when filtering only last 7 days of sleep records' do
      let!(:old_sleep_record) do
        create(
          :sleep_record,
          user: followed_user_1,
          sleep_at: 2.weeks.ago,
          wake_up_at: 13.days.ago,
          created_at: 2.weeks.ago,
          updated_at: 2.weeks.ago
        )
      end

      let!(:recent_sleep_record) do
        create(
          :sleep_record,
          user: followed_user_1,
          sleep_at: 3.days.ago,
          wake_up_at: 2.days.ago,
          created_at: 3.days.ago,
          updated_at: 3.days.ago
        )
      end

      it 'is expected to exclude sleep records older than 7 days' do
        expect(subject.result).to include(recent_sleep_record)
        expect(subject.result).not_to include(old_sleep_record)
      end
    end
  end
end
