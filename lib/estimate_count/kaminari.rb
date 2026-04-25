# frozen_string_literal: true

# Kaminari adapter for estimate_count.
#
# Adds `#estimate_page` to `ActiveRecord::Relation` which behaves like
# Kaminari's `#page` but pre-populates `total_count` with an estimate from
# `#estimate_count`, skipping the expensive `COUNT(*)` query that Kaminari
# would otherwise issue to render page links.
#
#   User.active.estimate_page(params[:page])
#   User.active.estimate_page(params[:page], per_page: 50, threshold: 5000)
#
# The `threshold:` kwarg is forwarded to `#estimate_count` - when the
# estimate is below it, a real count is issued instead.

module EstimateCount
  module KaminariExtension
    def estimate_page(num = nil, per_page: nil, threshold: 1000)
      estimated = estimate_count(threshold: threshold)
      # Route through klass.page so we always pick up Kaminari's class-level
      # implementation, even if another paginator (e.g. will_paginate) has
      # also defined #page on ActiveRecord::Relation.
      paginated = klass.page(num).merge(self)
      paginated = paginated.per(per_page) if per_page
      paginated.instance_variable_set(:@total_count, estimated)
      paginated
    end
  end

  module KaminariClassExtension
    def estimate_page(num = nil, **kwargs)
      all.estimate_page(num, **kwargs)
    end
  end
end

ActiveRecord::Relation.include(EstimateCount::KaminariExtension)
ActiveRecord::Base.extend(EstimateCount::KaminariClassExtension)
