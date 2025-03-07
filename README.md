# Good Night - Sleep Tracking API

A RESTful API for the Good Night mobile application that helps users track their sleep patterns and connect with friends.

## Overview

Good Night is a sleep tracking application that allows users to record their sleep times and durations. The application also includes social features, enabling users to follow others and view a feed of sleep records from users they follow.

## Features

### Sleep Tracking

- Record when you go to sleep
- Record when you wake up
- Automatically calculate sleep duration
- View your sleep history

### Social Features

- Follow/unfollow other users
- View a feed of sleep records from users you follow
- See detailed sleep statistics of yourself and others

## Tech Stack

- **Backend**: Ruby on Rails 8 (API-only)
- **Database**: MySQL
- **Caching**: Redis
- **Background Processing**: Sidekiq (currently not used, but in case needed we can use it)
- **API Documentation**: Rswag
- **Testing**: RSpec
- **Pagination**: Kaminari

## Setup Instructions

### Prerequisites

- Ruby 3.3+
- MySQL 8.0+
- Redis 7.0+
- Docker (for containerized setup)

### Local Development Setup

1. Clone the repository

   ```bash
   git clone https://github.com/khrisnagunanasurya/good-night.git
   cd good-night
   ```

2. Install dependencies

   ```bash
   bundle install
   ```

3. Set up database

   ```bash
   rails db:create
   rails db:migrate
   rails db:seed  # Optional, adds sample data (will be really slow actually, as its generating millions of user relations and sleep records)
   ```

4. Start the Redis server

   ```bash
   redis-server
   ```

5. Start Sidekiq for background jobs

   ```bash
   bundle exec sidekiq
   ```

6. Start the Rails server
   ```bash
   rails server
   ```

### Docker Setup

1. Build the Docker image

   ```bash
   docker compose build
   ```

2. Start all services

   ```bash
   docker compose up -d
   ```

3. Create and set up the database (first time only)
   ```bash
   docker compose run --rm web rails db:create db:migrate
   ```

## Testing

Run the test suite with:

```bash
docker compose run --rm -e RAILS_ENV=test web rspec
```

## API Documentation

API documentation is generated with Rswag and can be accessed at:

```
http://localhost:3000/api-docs
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
