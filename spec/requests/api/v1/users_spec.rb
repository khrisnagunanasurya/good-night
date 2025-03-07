require 'swagger_helper'

RSpec.describe 'API::V1::Users', type: :request do
  path '/api/v1/users/{user_id}/feed' do
    parameter name: :user_id, in: :path, type: :integer, description: 'User ID'
    parameter name: :page, in: :query, type: :integer, description: 'Page number'
    parameter name: :per_page, in: :query, type: :integer, description: 'Records per page'

    let(:page) { 1 }
    let(:per_page) { 10 }

    get 'Retrieves user sleep feed' do
      tags 'Users'
      produces 'application/json'

      response '200', 'feed found' do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: { '$ref' => '#/components/schemas/sleep_record' }
                 },
                 pagination: { '$ref' => '#/components/schemas/pagination' }
               }

        let!(:user) { create(:user) }
        let!(:followed_user) { create(:user) }
        let!(:relationship) { create(:relationship, follower: user, followed_user: followed_user) }
        let!(:sleep_record1) { create(:sleep_record, user: followed_user, duration: 36000, sleep_at: 2.days.ago) }
        let!(:sleep_record2) { create(:sleep_record, user: followed_user, duration: 40000, sleep_at: 1.day.ago) }
        let(:user_id) { user.id }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['data'].size).to eq(2)
          expect(json['data'][0]['id']).to eq(sleep_record2.id)
          expect(json['data'][1]['id']).to eq(sleep_record1.id)
          expect(json['pagination']['current_page']).to eq(1)
          expect(response.content_type).to eq('application/json; charset=utf-8')
        end
      end

      response '200', 'user has no sleep records' do
        schema type: :object,
               properties: {
                 data: { type: :array, items: {} },
                 pagination: { '$ref' => '#/components/schemas/pagination' }
               }

        let!(:user) { create(:user) }
        let(:user_id) { user.id }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['data']).to eq([])
          expect(json['pagination']['total_count']).to eq(0)
          expect(response.content_type).to eq('application/json; charset=utf-8')
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

  path '/api/v1/users' do
    get 'Retrieves a list of users' do
      tags 'Users'
      produces 'application/json'

      response '200', 'users found' do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: { '$ref' => '#/components/schemas/user' }
                 },
                 pagination: { '$ref' => '#/components/schemas/pagination' }
               }

        let!(:user1) { create(:user) }
        let!(:user2) { create(:user) }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['data'].length).to eq(2)
          expect(json['data'][0]['name']).to eq(user1.name)
          expect(json['data'][1]['name']).to eq(user2.name)
          expect(json['pagination']['current_page']).to eq(1)
          expect(response.content_type).to eq('application/json; charset=utf-8')
        end
      end

      response '200', 'no users found' do
        schema type: :object,
               properties: {
                 data: { type: :array, items: {} },
                 pagination: { '$ref' => '#/components/schemas/pagination' }
               }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['data']).to eq([])
          expect(json['pagination']['total_count']).to eq(0)
        end
      end
    end
  end

  path '/api/v1/users/{id}' do
    parameter name: :id, in: :path, type: :integer, description: 'User ID'

    get 'Retrieve a user' do
      tags 'Users'
      produces 'application/json'

      response '200', 'user exists' do
        schema type: :object, properties: {
          data: { '$ref' => '#/components/schemas/user' }
        }

        let!(:user) { create(:user) }
        let(:id) { user.id }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['name']).to eq(user.name)
          expect(response.content_type).to eq('application/json; charset=utf-8')
        end
      end

      response '404', 'user not exists' do
        schema '$ref' => '#/components/schemas/errors'

        let(:id) { -1 }

        run_test! do |response|
          expect(response).to have_http_status(:not_found)
        end
      end
    end
  end
end
