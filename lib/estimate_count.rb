# frozen_string_literal: true

require_relative "estimate_count/version"
require "active_record"

module ActiveRecord
  class Base
    def self.estimate_count(threshold: 1000)
      full_scope = current_scope&.limit(nil)&.offset(nil) || all
      rows = estimate_rows(full_scope.to_sql)
      rows = full_scope.count if threshold.is_a?(Integer) && rows < threshold
      rows
    end

    private_class_method def self.estimate_rows(query)
      case connection.adapter_name
      when "PostgreSQL"
        estimate_rows_postgresql(query)
      when "MySQL", "Mysql2"
        estimate_rows_mysql(query)
      else
        raise "Unsupported database"
      end
    end

    private_class_method def self.estimate_rows_postgresql(query)
      connection.execute("EXPLAIN #{query}").to_a.first["QUERY PLAN"].match(/rows=(\d+)/)[1].to_i
    end

    private_class_method def self.estimate_rows_mysql(query)
      result = connection.execute("EXPLAIN FORMAT=TRADITIONAL #{query}")
      index = result.fields.index("rows")
      result.first[index].to_i
    end
  end
end
