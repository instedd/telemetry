source 'https://rubygems.org'

# Declare your gem's dependencies in instedd_telemetry.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

# To use a debugger
# gem 'byebug', group: [:development, :test]

ruby_1_9 = /1\.9*/ =~ RUBY_VERSION

rails_version = ENV["RAILS_VERSION"] || "default"
rails_version_spec = case rails_version
when "default"
  nil
else
  "~> #{rails_version}"
end

gem 'rails', rails_version_spec
gem 'test-unit'

# see https://github.com/rails/rails/issues/21889
gem 'rack-cache', "~> 1.2.0" if ruby_1_9

gem `mime-types-data`, "~> 2.99.1" if ruby_1_9

group :test do
  gem 'timecop'
  gem 'webmock'
  gem 'capybara'
end

group :development, :test do
  gem 'pry-byebug' unless ENV["TRAVIS"] || ruby_1_9
end
