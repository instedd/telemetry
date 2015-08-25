class InsteddTelemetry::Agent
  def initialize
  end

  def auto_start
    start if should_start?
  end

  def start
    Thread.new do
      while true
        p "AGENT RUNNING"
        sleep 10
      end
    end
  end

  def should_start?
    !blacklisted_constants && !blacklisted_executables && !blacklisted_rake_task
  end

  private

  def blacklisted_constants
    ['Rails::Console'].any?{|x| is_constant_defined? x}
  end

  def blacklisted_executables
    ['irb', 'rspec'].any?{|x| x == File.basename($0)}
  end

  def blacklisted_rake_task
    tasks = ::Rake.application.top_level_tasks rescue []
    !(tasks & BLACKLISTED_RAKE_TASKS).empty?
  end

  def is_constant_defined?(name)
    !name.constantize.nil? rescue false
  end

  BLACKLISTED_RAKE_TASKS = [
    'about',
    'assets:clean',
    'assets:clobber',
    'assets:environment',
    'assets:precompile',
    'assets:precompile:all',
    'db:create',
    'db:drop',
    'db:fixtures:load',
    'db:migrate',
    'db:migrate:status',
    'db:rollback',
    'db:schema:cache:clear',
    'db:schema:cache:dump',
    'db:schema:dump',
    'db:schema:load',
    'db:seed',
    'db:setup',
    'db:structure:dump',
    'db:version',
    'doc:app',
    'log:clear',
    'middleware',
    'notes',
    'notes:custom',
    'rails:template',
    'rails:update',
    'routes',
    'secret',
    'spec',
    'spec:features',
    'spec:requests',
    'spec:controllers',
    'spec:helpers',
    'spec:models',
    'spec:views',
    'spec:routing',
    'spec:rcov',
    'stats',
    'test',
    'test:all',
    'test:all:db',
    'test:recent',
    'test:single',
    'test:uncommitted',
    'time:zones:all',
    'tmp:clear',
    'tmp:create'
  ]
end
