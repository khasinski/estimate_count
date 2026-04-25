# frozen_string_literal: true

require "estimate_count"
require "active_record"

# Load paginators for adapter specs. Order matters when both Kaminari and
# will_paginate are present in the same process: they each define `page` on
# `ActiveRecord::Relation`, and the last one loaded wins. Kaminari must be
# required AFTER will_paginate so the kaminari adapter spec sees Kaminari's
# `page` (will_paginate's `paginate` is unaffected and works either way).
%w[
  will_paginate
  will_paginate/active_record
  kaminari
  pagy
].each do |lib|
  begin
    require lib
  rescue LoadError
    # Paginator gem isn't installed - the matching adapter spec will skip.
  end
end

require "estimate_count/will_paginate" if defined?(WillPaginate)
require "estimate_count/kaminari" if defined?(Kaminari)
require "estimate_count/pagy" if defined?(Pagy)

WILL_PAGINATE_LOADED = defined?(WillPaginate) ? true : false
KAMINARI_LOADED = defined?(Kaminari) ? true : false
PAGY_LOADED = defined?(Pagy) ? true : false

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
