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
        let!(:user) { create(:user) }
        let(:user_id) { user.id }

        let!(:followed_user) { create(:user) }
        let(:relationship) { { target_user_id: followed_user.id } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(response).to have_http_status(:created)
          expect(data['message']).to eq('User followed successfully')
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
end
