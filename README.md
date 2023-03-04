# Estimate Count

This gems help with a common pagination problem in which the calculation of total number of pages takes too long.

Currently only PostgreSQL is supported.

## Problem

Let's say you have a table with 1 million records and you want to paginate it. You add filters and sorting. You can use the `count` method to get the total number of records in the table. However, this method will take a long time to execute. This is because the database has to count all the records in the table.

## Example
Given the following code:

```ruby
# app/models/user.rb
class User < ApplicationRecord
  scope :active, -> { where(active: true) }
  scope :name_like, ->(name) { where("name ILIKE ?", "%#{name}%") }
end

# app/controllers/users_controller.rb
class UsersController < ApplicationController
  def index
    @users = User.active.name_like(params[:name]).order(:name).page(params[:page])
  end
end
```
In a view:

```ruby
# app/views/users/index.html.erb
Total pages - <%= @users.total_pages %>
```
The above code will work fine. However, if you have a table with 1 million records, the `count` method will take a long time to execute. This is because the database has to count all the records in the table.

```ruby
# app/views/users/index.html.erb
Total pages - About <%= (@users.estimate_count / @users.per_page).ceil  %>
```

This extracts the estimation from PostgreSQL statistics and uses it to calculate the total number of pages. This is much faster than the `count` method. 

You can use it with any pagination library (or without one).

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add estimate_count

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install estimate_count

## Usage

This gem adds a method `#estimate_count` to the `ActiveRecord::Relation` class.

You can use it for any scope

```ruby
User.active.estimate_count
# It works with multiple scopes
Payment.with_deleted.where(created_at: ..1.month.ago).estimate_count
```

You can pass threshold named argument to determine when estimate should fall back to a regular count.

```ruby
# If estimate is > 1000, use estimate, otherwise use count
User.active.estimate_count(threshold: 1000)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. 

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/khasinski/estimate_count. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/estimate_count/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the EstimateCount project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/estimate_count/blob/master/CODE_OF_CONDUCT.md).
