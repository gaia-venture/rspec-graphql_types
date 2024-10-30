# frozen_string_literal: true

require_relative "graphql_types/version"
require "active_support"
require "graphql"

module Rspec
  module GraphQLTypes
    extend ActiveSupport::Concern

    class TestQuery < ::GraphQL::Query::NullContext::NullQuery
      attr_reader :context, :schema, :multiplex

      def initialize(context:, schema:)
        super()
        @context = context
        @schema = schema
        @multiplex = false
      end

      def trace(_key, _data)
        yield
      end

      def handle_or_reraise(err)
        schema.handle_or_reraise(context, err)
      end

      def warden
        @warden ||= ::GraphQL::Query::NullContext::NullWarden.new(
          ::GraphQL::Filter.new,
          context: context,
          schema: schema
        )
      end
    end

    included do
      let(:context_values) { nil }
      let(:schema) { ::GraphQL::VERSION.start_with?("1") ? GraphQLTypes.schema_class.new : GraphQLTypes.schema_class }
      let(:context) {
        ::GraphQL::Query::Context.new(
          query: TestQuery.new(context: self, schema: schema),
          values: context_values,
          object: nil,
          schema: schema
        )
      }
    end

    def graphql_object(type, value)
      if value.nil?
        raise "Received a nil value for #{type}" if type.non_null?
        return nil
      end
      case type.kind.name
      when 'OBJECT'
        type.authorized_new(value, context)
      when 'NON_NULL'
        graphql_object(type.of_type, value)
      when 'SCALAR'
        type.coerce_result(value, context)
      when 'LIST'
        value.map { |v| graphql_object(type.of_type, v) }
      when 'ENUM'
        type.coerce_result(value, context)
      else
        raise "Unknown type kind #{type.kind.name}"
      end
    end

    def graphql_field(object, field, **field_arguments)
      field_name = field.to_s.camelize(:lower)
      graphql_field = object.class.fields[field_name]
      raise "Could not find field #{field_name} on #{object.class}" unless graphql_field
      arguments = GraphQLTypes.build_arguments(graphql_field, field_arguments)
      value = context.dataloader.run_isolated do
        graphql_field.resolve(object, arguments, context)
      end
      raise value if value.is_a?(Exception)
      graphql_object(graphql_field.type, value)
    end

    def self.build_arguments(graphql_field, field_arguments)
      arguments = {}
      graphql_field.arguments.values.each do |arg|
        arguments[arg.keyword] = arg.default_value if arg.default_value?
      end
      field_arguments.each do |key, value|
        raise "Invalid Argument #{key}" unless graphql_field.arguments[key.to_s.camelize(:lower)]
        arguments[key] = value
      end
      arguments
    end

    def self.schema_class
      schemas = ::GraphQL::Schema.subclasses
                                 .filter { |schema| !schema.name.start_with?("GraphQL::") }
                                 .filter { |schema| !schema.name.ends_with?("::SCHEMA") }
      raise "Could not find valid schema. Please ensure that GraphQL::Schema.subclasses returns a single schema" unless schemas.length == 1
      schemas.first
    end
  end
end
