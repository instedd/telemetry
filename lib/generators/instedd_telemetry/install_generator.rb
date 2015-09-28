require 'active_record'
require 'rails/generators'
require 'rails/generators/base'

module InsteddTelemetry
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../../templates", __FILE__)

      desc "Installs InSTEDD Telemetry"

      def copy_initializer
        template "instedd_telemetry.rb", "config/initializers/instedd_telemetry.rb"
      end

      def insert_css
        extensions = %w(css scss css.scss)
        files = extensions.map{|x| "app/assets/stylesheets/application.#{x}"}
        found = files.find{|x| File.exists? x}

        if found
          content = File.binread(found)

          if content.include?("*= require_tree .")
            insert_into_file found, :after => "*= require_tree .\n" do
              " *= require instedd_telemetry\n"
            end
          elsif content.include?("*= require_self")
            insert_into_file found, :after => "*= require_self\n" do
              " *= require instedd_telemetry\n"
            end
          else
            say_status("skipped", "insert into #{found}", :yellow)
          end
        else
          say_status("skipped", "insert css require", :yellow)
        end
      end

      def mount_engine_in_routes
        route "mount InsteddTelemetry::Engine => '/instedd_telemetry'"
      end

      def install_migrations
        on_skip = Proc.new do |name, migration|
          puts "NOTE: Migration #{migration.basename} from #{name} has been skipped. Migration with the same name already exists."
        end

        on_copy = Proc.new do |name, migration|
          puts "Copied migration #{migration.basename} from #{name}"
        end

        railtie = InsteddTelemetry::Engine

        paths = {railtie.railtie_name => InsteddTelemetry::Engine.paths['db/migrate'].first}

        ActiveRecord::Migration.copy(ActiveRecord::Migrator.migrations_paths.first, paths, :on_skip => on_skip, :on_copy => on_copy)
      end

      def show_readme
        readme "README" if behavior == :invoke
      end
    end
  end
end
