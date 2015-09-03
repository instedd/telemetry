$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "instedd_telemetry/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "instedd_telemetry"
  s.version     = InsteddTelemetry::VERSION
  s.authors     = ["Juan Edi"]
  s.email       = ["jedi@manas.com.ar"]
  s.homepage    = "https://github.com/instedd/telemetry_rails"
  s.summary     = "Recollect and report usage stats for InSTEDD applications"

  s.files = Dir["{app,config,db,lib}/**/*", "Rakefile", "README.rdoc"]

  s.add_dependency "rails"

  s.add_development_dependency "sqlite3"
  
  s.add_development_dependency 'rspec-rails'
  s.test_files = Dir["spec/**/*"]
end
