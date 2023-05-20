# Estimate Count

This gems help with a common pagination problem in which the calculation of total number of pages takes too long.

Currently only PostgreSQL and MySQL are supported.

## Problem

Let's say you have a table with 1 million records and you want to paginate it. You add filters and sorting. 

Suddenly your performance drops even though you're only displaying a few records per page.

The problematic part is `#count`, which causes the entire scope to be calculated and then counted. This is slow.  However you can use table statistics to estimate the number of records in the table (same as `rows` in `EXPLAIN`). This is much faster.

Be aware though that this rely on table statistics being refreshed from time to time.

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
If you want to use estimate number of pages change the above line to:

```ruby
# app/views/users/index.html.erb
Total pages - About <%= (@users.estimate_count / @users.per_page).ceil %>
```

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add estimate_count

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install estimate_count

## Usage

This gem adds a method `#estimate_count` to the `ActiveRecord::Relation` class.

You can use it for any scope:

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

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. 

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/khasinski/estimate_count. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/estimate_count/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the EstimateCount project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/estimate_count/blob/master/CODE_OF_CONDUCT.md).
