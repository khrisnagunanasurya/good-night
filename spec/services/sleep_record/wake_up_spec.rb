RSpec.describe SleepRecord::WakeUp, type: :service do
  let(:user) { create(:user) }
  subject { described_class.call(user: user) }

  describe '#execute' do
    context 'when waking up successfully' do
      let!(:sleep_record) { create(:sleep_record, user: user, sleep_at: 2.hours.ago, wake_up_at: nil) }

      it 'is expected to update the wake_up_at time of the last sleep record' do
        expect { subject }.to change { sleep_record.reload.wake_up_at }.from(nil)
      end

      it 'is expected to update the duration time in seconds of the last sleep record' do
        expect { subject }.to change { sleep_record.reload.duration }.from(0).to(7200)
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

    context 'when the user has no sleep record' do
      it 'is expected to return an error' do
        service = described_class.call(user: user)

        expect(service.success?).to be_falsey
        expect(service.error_message).to eq("You haven't sleep yet")
      end
    end

    context 'when the last sleep record already has a wake_up_at time' do
      before do
        create(:sleep_record, user: user, sleep_at: 5.hours.ago, wake_up_at: 3.hours.ago)
      end

      it 'is expected to return an error' do
        service = described_class.call(user: user)

        expect(service.success?).to be_falsey
        expect(service.error_message).to eq("You haven't sleep yet")
      end
    end
  end
end
