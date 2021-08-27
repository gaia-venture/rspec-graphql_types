# Rspec::GraphQLTypes

This library can be used to unit test GraphQL types from the 'graphql' library.

## Installation

Add this line to your application's Gemfile:

```ruby
group :development, :test do
  gem 'rspec-graphql_types'
end
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install rspec-graphql_types

## Usage

Add the following to your rails_helper.rb

```ruby
RSpec.configure do |config|
  config.include Rspec::GraphQLTypes, type: :graphql_type
end
```

Then you can write tests as follows

```ruby
RSpec.describe Types::MyType, type: :graphql_type do
  it "does something awesome" do
    object = graphql_object(Types::MyTypes, {passed: in})
    expect(graphql_field(object, :field_name, arg1: value1, arg2: value2)).to eq("The Result")
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/rspec-graphql_types. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/rspec-graphql_types/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Rspec::GraphqlTypes project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/rspec-graphql_types/blob/main/CODE_OF_CONDUCT.md).
