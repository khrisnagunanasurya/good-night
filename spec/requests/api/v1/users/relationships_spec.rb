require 'swagger_helper'

RSpec.describe 'Api::V1::Users::RelationshipsController', type: :request do
  path '/api/v1/users/{user_id}/relationships' do
    parameter name: :user_id, in: :path, type: :integer, description: 'ID of the user who is following'

    post 'Follows a user' do
      tags 'Relationships'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :relationship, in: :body, schema: {
        type: :object,
        properties: {
          target_user_id: { type: :integer, description: 'ID of the user to be followed' }
        },
        required: ['target_user_id']
      }

      response '201', 'user followed successfully' do
        schema type: :object,
               properties: {
                 data: { '$ref' => '#/components/schemas/relationship' }
               }

        let!(:user) { create(:user) }
        let(:user_id) { user.id }

        let!(:followed_user) { create(:user) }
        let(:relationship) { { target_user_id: followed_user.id } }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(response).to have_http_status(:created)
          expect(json['data']['follower_id']).to eq user_id
          expect(json['data']['followed_user_id']).to eq followed_user.id
        end
      end

      response '422', 'target user not found' do
        schema '$ref' => '#/components/schemas/errors'

        let!(:user) { create(:user) }
        let(:user_id) { user.id }
        let(:relationship) { { target_user_id: -1 } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(response).to have_http_status(:unprocessable_content)
          expect(data['error']['message']).to eq('Invalid follower or followed user.')
        end
      end

      response '422', 'can\'t follow yourself' do
        schema '$ref' => '#/components/schemas/errors'

        let!(:user) { create(:user) }
        let(:user_id) { user.id }
        let(:relationship) { { target_user_id: user.id } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(response).to have_http_status(:unprocessable_content)
          expect(data['error']['message']).to eq('User cannot follow themselves.')
        end
      end
    end
  end

  path '/api/v1/users/{user_id}/relationships/{target_user_id}' do
    parameter name: :user_id, in: :path, type: :integer, description: 'ID of the user who is unfollowing'
    parameter name: :target_user_id, in: :path, type: :integer, description: 'ID of the target user who is followed'

    delete 'Unfollows a user' do
      tags 'Relationships'
      consumes 'application/json'
      produces 'application/json'

      response '204', 'user unfollowed successfully' do
        let!(:user) { create(:user) }
        let(:user_id) { user.id }

        let!(:followed_user) { create(:user) }
        let(:target_user_id) { followed_user.id }

        before do
          Relationship.create(follower: user, followed_user: followed_user)
        end

        run_test! do |response|
          expect(response).to have_http_status(:no_content)
        end
      end

      response '422', 'target user not found' do
        schema '$ref' => '#/components/schemas/errors'

        let!(:user) { create(:user) }
        let(:user_id) { user.id }
        let(:target_user_id) { -1 }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(response).to have_http_status(:unprocessable_content)
          expect(data['error']['message']).to eq('Invalid unfollower or unfollowed user.')
        end
      end

      response '422', 'can\'t unfollow yourself' do
        schema '$ref' => '#/components/schemas/errors'

        let!(:user) { create(:user) }
        let(:user_id) { user.id }
        let(:target_user_id) { user_id }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(response).to have_http_status(:unprocessable_content)
          expect(data['error']['message']).to eq('User cannot unfollow themselves.')
        end
      end

      response '422', 'can\'t unfollow an unfollowed user' do
        schema '$ref' => '#/components/schemas/errors'

        let!(:user) { create(:user) }
        let(:user_id) { user.id }

        let!(:followed_user) { create(:user) }
        let(:target_user_id) { followed_user.id }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(response).to have_http_status(:unprocessable_content)
          expect(data['error']['message']).to eq('User is not following this person.')
        end
      end
    end
  end
end
