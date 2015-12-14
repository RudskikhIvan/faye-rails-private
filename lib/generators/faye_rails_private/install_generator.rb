module FayeRailsPrivate
  module Generators
    class InstallGenerator < Rails::Generators::Base
      def self.source_root
        File.dirname(__FILE__) + "/templates"
      end

      def copy_files
        copy_file "faye_rails_private.rb", "config/initializers/faye_rails_private.rb"
      end
    end
  end
end