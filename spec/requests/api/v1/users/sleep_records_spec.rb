require 'swagger_helper'

RSpec.describe 'Api::V1::Users::SleepRecordsController', type: :request do
  path '/api/v1/users/{user_id}/sleep' do
    parameter name: :user_id, in: :path, type: :integer, description: 'ID of the user'

    post 'Creates a sleep record' do
      tags 'SleepRecords'
      consumes 'application/json'
      produces 'application/json'

      response '201', 'sleep record created successfully' do
        let!(:user) { create(:user) }
        let(:user_id) { user.id }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(response).to have_http_status(:created)
          expect(data['message']).to eq('Sleep record created successfully')
        end
      end

      response '404', 'user not found' do
        let(:user_id) { -1 }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(response).to have_http_status(:not_found)
          expect(data['error']['message']).to eq('Not found')
        end
      end

      response '422', 'user already has an ongoing sleep record' do
        let!(:user) { create(:user) }
        let(:user_id) { user.id }

        before do
          create(:sleep_record, user: user, sleep_at: Time.current, wake_up_at: nil)
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(response).to have_http_status(:unprocessable_content)
          expect(data['error']['message']).to eq('You already have an ongoing sleep record')
        end
      end
    end
  end
end
