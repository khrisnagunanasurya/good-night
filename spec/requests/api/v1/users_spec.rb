# spec/requests/api/v1/users_spec.rb
require 'swagger_helper'

RSpec.describe 'API::V1::Users', type: :request do
  path '/api/v1/users' do
    get 'Retrieves a list of users' do
      tags 'Users'
      produces 'application/json'

      response '200', 'users found' do
        schema type: :array,
               items: { '$ref' => '#/components/schemas/user' }

        let!(:user1) { User.create(name: 'Alice') }
        let!(:user2) { User.create(name: 'Bob') }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data.length).to eq(2)
          expect(data[0]['name']).to eq('Alice')
          expect(data[1]['name']).to eq('Bob')
          expect(response.content_type).to eq('application/json; charset=utf-8')
        end

        context 'when there are no users' do
          let!(:user1) {}
          let!(:user2) {}
          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data.length).to eq(0)
          end
        end
      end
    end

    post 'Creates a user' do
      tags 'Users'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :user, in: :body, schema: {
        '$ref' => '#/components/schemas/user_create'
      }

      response '201', 'user created' do
        schema '$ref' => '#/components/schemas/user'

        let(:user) { { name: 'Charlie' } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['name']).to eq('Charlie')
          expect(User.count).to eq(1)
          expect(User.last.name).to eq('Charlie')
          expect(response.content_type).to eq('application/json; charset=utf-8')
        end
      end

      response '422', 'invalid request' do
        schema '$ref' => '#/components/schemas/errors'

        let(:user) { { name: '' } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(response.status).to eq(422)
          expect(data['error']['details']).to include('name')
          expect(data['error']['details']['name']).to include("can't be blank")
          expect(User.count).to eq(0)
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
        schema '$ref' => '#/components/schemas/user'

        let!(:user) { User.create(name: 'Alice') }
        let(:id) { user.id }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['name']).to eq('Alice')
          expect(response.content_type).to eq('application/json; charset=utf-8')
        end
      end

      response '404', 'user not exists' do
        schema '$ref' => '#/components/schemas/errors'

        let(:id) { 'non-existing' }

        run_test! do |response|
          expect(response.status).to eq(404)
        end
      end
    end

    delete 'Deletes a user' do
      tags 'Users'
      produces 'application/json'

      response '204', 'user deleted' do
        let!(:user) { User.create(name: 'David') }
        let(:id) { user.id }

        run_test! do |response|
          expect(response.status).to eq(204)
          expect(response.body).to be_empty
          expect(User.exists?(user.id)).to be_falsey
        end
      end

      response '404', 'user not exists' do
        schema '$ref' => '#/components/schemas/errors'

        let(:id) { 'non-existing' }

        run_test! do |response|
          expect(response.status).to eq(404)
        end
      end
    end
  end
end
