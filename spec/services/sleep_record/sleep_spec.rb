RSpec.describe SleepRecord::Sleep, type: :service do
  let(:user) { create(:user) }

  subject { described_class.call(user: user) }

  describe '#execute' do
    context 'when creating a sleep record successfully' do
      it 'is expected to create a new sleep record' do
        expect { subject }.to change { SleepRecord.count }.by(1)

        sleep_record = SleepRecord.last

        expect(sleep_record.user).to eq(user)
        expect(sleep_record.sleep_at).to be_present
        expect(sleep_record.wake_up_at).to be_nil
      end
    end

    context 'when user is invalid' do
      it 'is expected to return an error if user is nil' do
        service = described_class.call(user: nil)

        expect(service.success?).to be_falsey
        expect(service.error_message).to eq('Invalid user.')
      end

      it 'is expected to return an error if user is not a persisted User object' do
        new_user = build(:user)
        service = described_class.call(user: new_user)

        expect(service.success?).to be_falsey
        expect(service.error_message).to eq('Invalid user.')
      end
    end

    context 'when the user already has an ongoing sleep record' do
      before do
        create(:sleep_record, user: user, sleep_at: 2.hours.ago, wake_up_at: nil)
      end

      it 'is expected to return an error' do
        service = described_class.call(user: user)

        expect(service.success?).to be_falsey
        expect(service.error_message).to eq('You already have an ongoing sleep record')
      end
    end

    context 'when the user has a past sleep record with wake up time' do
      before do
        create(:sleep_record, user: user, sleep_at: 5.hours.ago, wake_up_at: 3.hours.ago)
      end

      it 'is expected to create a new sleep record' do
        expect { subject }.to change { SleepRecord.count }.by(1)
      end
    end

    context 'when multiple requests are made simultaneously', transactional: false do
      it 'is expected to ensure only one sleep record is created' do
        expect do
          threads = []
          5.times do
            threads << Thread.new do
              ActiveRecord::Base.connection_pool.with_connection do
                described_class.call(user: user)
              end
            end
          end
          threads.each(&:join) # Wait for both threads to finish

          SleepRecord.connection.execute('COMMIT')
        end.to change { SleepRecord.count }.by(1)
      end
    end
  end
end
