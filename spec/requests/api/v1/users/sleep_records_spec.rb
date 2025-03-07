require 'swagger_helper'

RSpec.describe 'Api::V1::Users::SleepRecordsController', type: :request do
  path '/api/v1/users/{user_id}/sleep_records' do
    parameter name: :user_id, in: :path, type: :integer, description: 'User ID'
    parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
    parameter name: :per_page, in: :query, type: :integer, required: false, description: 'Number of items per page'

    let(:page) { 1 }
    let(:per_page) { 10 }

    get 'Retrieves a user’s sleep records' do
      tags 'Sleep Records'
      produces 'application/json'

      response '200', 'sleep records found' do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: { '$ref' => '#/components/schemas/sleep_record' }
                 },
                 pagination: { '$ref' => '#/components/schemas/pagination' }
               }

        let!(:user) { create(:user) }
        let!(:sleep_record1) { create(:sleep_record, user: user, sleep_at: 2.days.ago, wake_up_at: 1.day.ago) }
        let!(:sleep_record2) { create(:sleep_record, user: user, sleep_at: 1.hour.ago) }
        let(:user_id) { user.id }
        let(:page) { 1 }
        let(:per_page) { 10 }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['data'].size).to eq(2)
          expect(json['pagination']['current_page']).to eq(page)
          expect(response.content_type).to eq('application/json; charset=utf-8')
        end
      end

      response '200', 'no sleep records found' do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: { '$ref' => '#/components/schemas/sleep_record' }
                 },
                 pagination: { '$ref' => '#/components/schemas/pagination' }
               }

        let!(:user) { create(:user) }
        let(:user_id) { user.id }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['data']).to eq([])
        end
      end

      response '404', 'user not found' do
        schema '$ref' => '#/components/schemas/errors'

        let(:user_id) { -1 }

        run_test! do |response|
          expect(response).to have_http_status(:not_found)
        end
      end
    end
  end

  path '/api/v1/users/{user_id}/sleep' do
    parameter name: :user_id, in: :path, type: :integer, description: 'ID of the user'

    post 'Creates a sleep record' do
      tags 'Sleep Records'
      consumes 'application/json'
      produces 'application/json'

      response '201', 'sleep record created successfully' do
        schema type: :object,
               properties: {
                 data: { '$ref' => '#/components/schemas/sleep_record' }
               }

        let!(:user) { create(:user) }
        let(:user_id) { user.id }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(response).to have_http_status(:created)
          expect(json['data']['sleep_at']).not_to be_nil
          expect(json['data']['wake_up_at']).to be_nil
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

  path '/api/v1/users/{user_id}/wake_up' do
    parameter name: :user_id, in: :path, type: :integer, description: 'ID of the user'

    post 'Updates a wake-up record' do
      tags 'Sleep Records'
      consumes 'application/json'
      produces 'application/json'

      response '200', 'wake up record created successfully' do
        schema type: :object,
               properties: {
                 data: { '$ref' => '#/components/schemas/sleep_record' }
               }

        let!(:user) { create(:user) }
        let!(:sleep_record) { create(:sleep_record, user: user, sleep_at: 2.hours.ago, wake_up_at: nil) }
        let(:user_id) { user.id }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(response).to have_http_status(:ok)
          expect(json['data']['sleep_at']).not_to be_nil
          expect(json['data']['wake_up_at']).not_to be_nil
          expect(json['data']['duration']).not_to eq 0
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

      response '422', 'user has no ongoing sleep record' do
        let!(:user) { create(:user) }
        let(:user_id) { user.id }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(response).to have_http_status(:unprocessable_content)
          expect(data['error']['message']).to eq("You haven't sleep yet")
        end
      end

      response '422', 'wake up already recorded' do
        let!(:user) { create(:user) }
        let!(:sleep_record) { create(:sleep_record, user: user, sleep_at: 3.hours.ago, wake_up_at: 1.hour.ago) }
        let(:user_id) { user.id }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(response).to have_http_status(:unprocessable_content)
          expect(data['error']['message']).to eq('You haven\'t sleep yet')
        end
      end
    end
  end
end
