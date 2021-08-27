# frozen_string_literal: true

class TestSchema < GraphQL::Schema
end

RSpec.describe Rspec::GraphQLTypes do
  it "has a version number" do
    expect(Rspec::GraphQLTypes::VERSION).not_to be nil
  end

  it "is able to get the schema class" do
    expect(Rspec::GraphQLTypes.schema_class).to eq(TestSchema)
  end
end
