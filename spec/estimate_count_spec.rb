# frozen_string_literal: true
require_relative "helpers/load_database"

RSpec.describe EstimateCount do
  def captured_sql
    captured = []
    callback = ->(_, _, _, _, payload) {
      sql = payload[:sql]
      captured << sql unless sql.start_with?("SCHEMA") || sql.include?("information_schema")
    }
    ActiveSupport::Notifications.subscribed(callback, "sql.active_record") { yield }
    captured
  end

  it "has a version number" do
    expect(EstimateCount::VERSION).not_to be nil
  end

  context "with a MySQL database" do
    before { load_database("mysql") }

    let!(:table) { MySQLTable.create(level: 1) }
    let!(:table_list) { 10_000.times.map { { level: 2 } } }
    let!(:table_objects) { MySQLTable.insert_all(table_list) }

    describe ".estimate_count" do
      before { ActiveRecord::Base.connection.execute("ANALYZE TABLE my_sql_tables") }

      it "returns the estimate from EXPLAIN when above threshold" do
        scope = MySQLTable.where(level: 2)
        expect(scope.estimate_count).to be_between(9_500, 10_500)
      end

      it "falls back to a real COUNT(*) when the estimate is below threshold" do
        scope = MySQLTable.where(level: 2)
        expect(scope.estimate_count(threshold: 15_000)).to eq(10_000)
      end

      it "skips the COUNT(*) fallback when threshold is nil" do
        sql = captured_sql { MySQLTable.where(level: 1).estimate_count(threshold: nil) }
        expect(sql).not_to include(a_string_matching(/SELECT COUNT/i))
      end

      it "ignores LIMIT/OFFSET on the scope" do
        scope = MySQLTable.where(level: 2).limit(5).offset(10)
        expect(scope.estimate_count).to be_between(9_500, 10_500)
      end
    end
  end

  context "with a PostgreSQL database" do
    before { load_database("postgresql") }

    let!(:table) { PostgreSQLTable.create(level: 1) }
    let!(:table_list) { 10_000.times.map { { level: 2 } } }
    let!(:table_objects) { PostgreSQLTable.insert_all(table_list) }

    describe ".estimate_count" do
      before { ActiveRecord::Base.connection.execute("ANALYZE postgre_sql_tables") }

      it "returns the estimate from EXPLAIN when above threshold" do
        scope = PostgreSQLTable.where(level: 2)
        expect(scope.estimate_count).to eq(10_000)
      end

      it "falls back to a real COUNT(*) when the estimate is below threshold" do
        scope = PostgreSQLTable.where(level: 2)
        expect(scope.estimate_count(threshold: 15_000)).to eq(10_000)
      end

      it "skips the COUNT(*) fallback when threshold is nil" do
        sql = captured_sql { PostgreSQLTable.where(level: 1).estimate_count(threshold: nil) }
        expect(sql).not_to include(a_string_matching(/SELECT COUNT/i))
      end

      it "ignores LIMIT/OFFSET on the scope" do
        scope = PostgreSQLTable.where(level: 2).limit(5).offset(10)
        expect(scope.estimate_count).to eq(10_000)
      end
    end
  end

  context "with an unsupported database adapter" do
    before { load_database("postgresql") }

    it "raises a clear error" do
      allow(ActiveRecord::Base.connection).to receive(:adapter_name).and_return("SQLite")

      expect { PostgreSQLTable.estimate_count(threshold: nil) }
        .to raise_error(RuntimeError, "Unsupported database")
    end
  end
end
