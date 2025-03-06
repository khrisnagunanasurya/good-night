# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.openapi_root = Rails.root.join('swagger').to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under openapi_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a openapi_spec tag to the
  # the root example_group in your specs, e.g. describe '...', openapi_spec: 'v2/swagger.json'
  config.openapi_specs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'Good Night API',
        version: 'v1',
        description: 'API for tracking sleep records'
      },
      paths: {},
      components: {
        schemas: {
          user: {
            type: :object,
            properties: {
              id: { type: :integer, example: 1 },
              name: { type: :string, example: 'Alice' },
              created_at: { type: :string, format: 'date-time', example: '2023-10-26T10:00:00Z' },
              updated_at: { type: :string, format: 'date-time', example: '2023-10-26T10:00:00Z' }
            },
            required: ['id', 'name', 'created_at', 'updated_at']
          },
          user_create: {
            type: :object,
            properties: {
              name: { type: :string, example: 'Charlie' }
            },
            required: ['name']
          },
          errors: {
            type: :object,
            properties: {
              error: {
                type: :object,
                properties: {
                  status: { type: :integer, example: 422, description: 'HTTP status code' },
                  message: { type: :string, example: 'Failed to create a user', description: 'General error message' },
                  details: {
                    type: :object,
                    description: 'Detailed error messages, keyed by attribute',
                    additionalProperties: {
                      type: :array,
                      items: {
                        type: :string,
                        example: "can't be blank"
                      },
                      description: 'Array of error messages for a specific attribute'
                    }
                  }
                },
                required: ['status', 'message', 'details']
              }
            },
            required: ['error']
          }
        }
      },
        servers: [
        {
          url: 'http://{defaultHost}',
          variables: {
            defaultHost: {
              default: 'localhost:3000'
            }
          }
        }
      ]
    }
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The openapi_specs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.openapi_format = :yaml
end
