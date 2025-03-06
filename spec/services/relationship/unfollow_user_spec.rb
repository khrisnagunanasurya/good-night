require 'rails_helper'

RSpec.describe Relationship::UnfollowUser, type: :service do
  let(:unfollower) { create(:user) }
  let(:unfollowed_user) { create(:user) }

  subject { described_class.call(unfollower: unfollower, unfollowed_user: unfollowed_user) }

  describe '#execute' do
    context 'when unfollowing a user successfully' do
      before do
        Relationship.create!(follower: unfollower, followed_user: unfollowed_user)
      end

      it 'is expected to remove the relationship' do
        expect { subject }.to change { Relationship.count }.by(-1)
      end
    end

    context 'when unfollower or unfollowed user is invalid' do
      it 'is expected to return an error if unfollower is nil' do
        service = described_class.call(unfollower: nil, unfollowed_user: unfollowed_user)

        expect(service.success?).to be_falsey
        expect(service.error_message).to eq('Invalid unfollower or unfollowed user.')
      end

      it 'is expected to return an error if unfollowed user is nil' do
        service = described_class.call(unfollower: unfollower, unfollowed_user: nil)

        expect(service.success?).to be_falsey
        expect(service.error_message).to eq('Invalid unfollower or unfollowed user.')
      end

      it 'is expected to return an error if unfollower is not a User object' do
        service = described_class.call(unfollower: 'invalid', unfollowed_user: unfollowed_user)

        expect(service.success?).to be_falsey
        expect(service.error_message).to eq('Invalid unfollower or unfollowed user.')
      end

      it 'is expected to return an error if unfollowed user is not a User object' do
        service = described_class.call(unfollower: unfollower, unfollowed_user: 'invalid')

        expect(service.success?).to be_falsey
        expect(service.error_message).to eq('Invalid unfollower or unfollowed user.')
      end
    end

    context 'when the unfollower tries to unfollow themselves' do
      it 'is expected to return an error' do
        service = described_class.call(unfollower: unfollower, unfollowed_user: unfollower)

        expect(service.success?).to be_falsey
        expect(service.error_message).to eq('User cannot unfollow themselves.')
      end
    end

    context 'when the user is not following the target user' do
      it 'is expected to return an error' do
        expect(subject.success?).to be_falsey
        expect(subject.error_message).to eq('User is not following this person.')
      end
    end
  end
end
