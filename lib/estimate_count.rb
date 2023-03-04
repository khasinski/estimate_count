# frozen_string_literal: true

require_relative "estimate_count/version"

module ActiveRecord
  class Base
    def self.estimate_count(threshold: 1000)
      full_scope = current_scope.limit(nil).offset(nil)
      rows = estimate_rows(full_scope.to_sql)
      rows = full_scope.count if threshold.is_a?(Integer) && rows < threshold
      rows
    end

    private_class_method def self.estimate_rows(query)
      connection.execute("EXPLAIN #{query}").to_a.first["QUERY PLAN"].match(/rows=(\d+)/)[1].to_i
    end
  end
end
