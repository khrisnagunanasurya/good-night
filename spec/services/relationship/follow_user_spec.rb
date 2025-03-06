RSpec.describe Relationship::FollowUser, type: :service do
  let(:follower) { create(:user) }
  let(:followed_user) { create(:user) }

  subject { described_class.call(follower: follower, followed_user: followed_user) }

  describe '#execute' do
    context 'when following a user successfully' do
      it 'is expected to create a new relationship' do
        expect { subject }.to change { Relationship.count }.by(1)
        expect(Relationship.first.follower).to eq(follower)
        expect(Relationship.first.followed_user).to eq(followed_user)
      end
    end

    context 'when follower or followed user is invalid' do
      it 'is expected to return an error if follower is nil' do
        service = described_class.call(follower: nil, followed_user: followed_user)

        expect(service.success?).to be_falsey
        expect(service.error_message).to eq('Invalid follower or followed user.')
      end

      it 'is expected to return an error if followed user is nil' do
        service = described_class.call(follower: follower, followed_user: nil)

        expect(service.success?).to be_falsey
        expect(service.error_message).to eq('Invalid follower or followed user.')
      end

      it 'is expected to return an error if follower is not a User object' do
        service = described_class.call(follower: 'invalid', followed_user: followed_user)

        expect(service.success?).to be_falsey
        expect(service.error_message).to eq('Invalid follower or followed user.')
      end

      it 'is expected to return an error if followed user is not a User object' do
        service = described_class.call(follower: follower, followed_user: 'invalid')

        expect(service.success?).to be_falsey
        expect(service.error_message).to eq('Invalid follower or followed user.')
      end
    end

    context 'when the follower tries to follow themselves' do
      it 'is expected to return an error' do
        service = described_class.call(follower: follower, followed_user: follower)

        expect(service.success?).to be_falsey
        expect(service.error_message).to eq('User cannot follow themselves.')
      end
    end

    context 'when the user is already following the target user' do
      before do
        Relationship.create!(follower: follower, followed_user: followed_user)
      end

      it 'is expected to return an error' do

        expect(subject.success?).to be_falsey
        expect(subject.error_message).to eq('Already following this user.')
      end
    end
  end
end
