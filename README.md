# Telemetry Rails

[![Build Status](https://travis-ci.org/instedd/telemetry_rails.svg)](https://travis-ci.org/instedd/telemetry_rails)

Integrate [InSTEDD Telemetry](https://github.com/instedd/telemetry_server) into a Ruby on Rails application.

## Installation

Add the gem to your Gemfile and run the bundle command.

```ruby
gem 'instedd_telemetry', git: 'https://github.com/instedd/telemetry_rails.git'
```

Execute the install generator:

```bash
rails generate instedd_telemetry:install
```

This will create a default initializer in `config/initializers/instedd_telemetry.rb`, append the gem's css require into `app/assets/stylesheets/application.css`, mount the engine's routes in the `routes.rb` file and copy the required migrations.
After this, you should manually migrate the database:

```bash
rake db:migrate
```

Lastly, add the telemetry warning into your views. This will display an alert informing the user the presence of telemetry in the application. Insert the following in you main application layout (usually
 `app/views/layouts/application.html.erb`):

 ```ruby
 <%= telemetry_warning %>
 ```
 
## Configuration

The default configuration can be overridden in the telemetry initializer (`config/initializers/instedd_telemetry.rb`):

```ruby
InsteddTelemetry.setup do |config|
  # Telemetry server URL
  config.server_url = "http://telemetry.instedd.org"

  # Telemetry remote API port, where the socket listens
  config.api_port = 8089

  # Application name
  config.application = 'verboice'
end
```

## Types of metrics

There are different types of metrics that can be used to report stats. These are `counters`, `sets` and `timespans`:

* **counters**: simple counters that hold an integer value.
* **sets**: sets hold unique occurrences of reported values.
* **timespans**: measure an interval of time.

## Report metrics

Metrics can be reported by using the different types of metrics. Each report is created with a _metric_ name that serves as an identifier for the metric and an optional dictionary of key attributes.

To report a counter:

```ruby
InsteddTelemetry.counter_add(metric, key_attributes, value)
```

To add an element to a set:

```ruby
InsteddTelemetry.set_add(metric, key_attributes, element)
```

For timespans:

```ruby
InsteddTelemetry.timespan_update(metric, key_attributes, since, until)
```

When created, these reports will be associated with a particular period of time and will be sent to the telemetry server when this period is ended.

Additionally, metrics can be reported by creating custom _collectors_ that run before any period is sent to the server. Collectors define a method where you can run custom code and return a dictionary that hold the different metrics to be reported.

The collector should define a static method named `collect_stats` that expects the period for this metric:

```ruby
module Telemetry::MyCustomCollector
  def self.collect_stats(period)
    ...
  end
end
```

The collector should return a hash with the following structure:

```ruby
{
  counters: [
    {
      metric: name_of_metric,
      key: key_dictionary,
      value: value_of_counter
    },
    ...
  ],
  sets: [
    {
      metric: name_of_metric,
      key: key_dictionary,
      elements: array_of_elements
    },
    ...
  ],
  timespans: [
    {
      metric: name_of_metric,
      key: key_dictionary,
      days: timespan_in_days
    },
    ...
  ]
}
```

Finally collectors should be hooked in the configuration file:

```ruby
InsteddTelemetry.setup do |config|
  ...

  config.add_collector Telemetry::MyCustomCollector
end
```

For example, to create a collector that counts active users:

```ruby
# active_users_collectors.rb
module Telemetry::ActiveUsersCollector
  def self.collect_stats(period)
    active_users_in_period = ... # calculate active users

    {
      counters: [
        metric: 'active_users',
        key: {},
        value: active_users_in_period  
      ]
    }
  end
end

# app/config/initializers/instedd_telemetry.rb
InsteddTelemetry.setup do |config|
  ...

  config.add_collector Telemetry::ActiveUsersCollector

  ...
end
```

## Remote API

This gem exposes a TCP socket that can be used to report metrics from external components. The socket listens in the port specified in the configuration and expects a JSON message that follows this structure:

```
{"command": command, "arguments": [argument1, argument2, ..., argumentN]}
```

Where command can be any of the name of the methods used to report metrics (`counter_add`, `set_add` and `timespan_update`). Arguments are sent as an array and follow each particular method signature.

Multiple reports can be sent at once by separating them by new lines:

```
{"command": command1, "arguments": [argument1_1, argument1_2, ..., argument1_N]}\n
{"command": command2, "arguments": [argument2_1, argument2_2, ..., argument2_N]}\n
...
```

For example, to report a counter with a metric name of `calls_per_project`, a dictionary `{project_id => 17}` and a value of `23`:

```json
{"command": "counter_add", "arguments": ["calls_per_project", {"project_id": 17}, 23]}
```

### Telemetry Erlang

[Telemetry Erlang](https://github.com/instedd/telemetry_erlang) is a remote API client written in Erlang and packed as a library. Use this to integrate Telemetry in an Erlang project along this gem or use it as reference implementation.

## Utilities

### Country code

Extracts the country code from a phone number. Returns the country code as a string if found or nil otherwise.

```ruby
InsteddTelemetry::Util.country_code(number)
```

In order to use this utility **you must** initialize a database. Run the following command:

```bash
rake global_phone:generate
```

This will create a file under `db/global_phone.json`. You should commit this file since it will be required by any installation that uses this utility method to calculate metrics.

## License

Telemetry Rails is released under the [GPLv3 license](LICENSE).
