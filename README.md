# ActiveJobQless

Qless Active Job adapter

## Installation

Add these lines to your application's Gemfile:

```ruby
gem 'qless'
gem 'active_job_qless'
```

## Usage

In `application.rb`:
```
config.active_job.queue_adapter = :qless
```

In `config/intializers/qless.rb`:
```
ActiveJobQless.redis_uri = "redis://localhost:6379" # or ENV['REDIS_URI']
ActiveJobQless.initialize_worker
```

To start the queue, you can create a rake task:
```
namespace :qless do
  desc "Start qless worker"
  task :start => :environment do
    ActiveJobQless.worker.start
  end
end
```

## Contributing

Bug reports and pull requests are very welcome on GitHub at https://github.com/[USERNAME]/active_job_qless.


## License

[MIT License](http://opensource.org/licenses/MIT).

