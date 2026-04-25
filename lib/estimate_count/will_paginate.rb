# frozen_string_literal: true

# will_paginate adapter for estimate_count.
#
# Adds `#estimate_paginate` to `ActiveRecord::Relation` which behaves like
# will_paginate's `#paginate` but pre-populates `:total_entries` with an
# estimate from `#estimate_count`. will_paginate will then skip its own
# `COUNT(*)` query when computing `total_pages`.
#
#   User.active.estimate_paginate(page: params[:page], per_page: 30)
#   User.active.estimate_paginate(page: params[:page], threshold: 5000)
#
# `:threshold` is forwarded to `#estimate_count`. Any other options are
# passed straight through to `#paginate`. If the caller already supplies
# `:total_entries` it wins - no estimate query is run.

module EstimateCount
  module WillPaginateExtension
    def estimate_paginate(options = {})
      options = options.dup
      threshold = options.delete(:threshold) { 1000 }
      options[:total_entries] ||= estimate_count(threshold: threshold)
      paginate(options)
    end
  end

  module WillPaginateClassExtension
    def estimate_paginate(options = {})
      all.estimate_paginate(options)
    end
  end
end

ActiveRecord::Relation.include(EstimateCount::WillPaginateExtension)
ActiveRecord::Base.extend(EstimateCount::WillPaginateClassExtension)
