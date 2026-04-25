# frozen_string_literal: true

# Pagy adapter for estimate_count.
#
# Pagy's `#pagy` backend method accepts a `:count` keyword which, when set,
# skips the internal `COUNT(*)` query. This mixin extends `Pagy::Backend`
# with `#pagy_estimate`, a drop-in replacement that computes the count via
# `#estimate_count` and forwards everything else to `#pagy`.
#
#   # in a controller
#   include Pagy::Backend
#
#   def index
#     @pagy, @users = pagy_estimate(User.active, items: 25)
#     # or tune the fallback threshold:
#     @pagy, @users = pagy_estimate(User.active, threshold: 5000)
#   end
#
# `:threshold` is consumed here and forwarded to `#estimate_count`.
# Every other keyword is passed straight through to `#pagy`. If the caller
# already supplies `:count` it wins - no estimate query is run.

module EstimateCount
  module PagyExtension
    def pagy_estimate(collection, **vars)
      threshold = vars.delete(:threshold) { 1000 }
      vars[:count] ||= collection.estimate_count(threshold: threshold)
      pagy(collection, **vars)
    end
  end
end

Pagy::Backend.include(EstimateCount::PagyExtension)
