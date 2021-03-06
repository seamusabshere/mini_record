require 'rubygems' unless defined?(Gem)
require 'bundler/setup'
require 'mini_record'
require 'minitest/autorun'

# require 'logger'
# ActiveRecord::Base.logger = Logger.new($stderr)
# ActiveRecord::Base.logger.level = Logger::DEBUG

module SpecHelper
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def db_columns
      connection.columns(table_name).map(&:name).sort
    end

    def db_indexes
      connection.indexes(table_name).map(&:name).sort
    end

    def schema_columns
      table_definition.columns.map { |c| c.name.to_s }.sort
    end
  end
end
