# frozen_string_literal: true
require_relative "helpers/load_database"

RSpec.describe EstimateCount do
  it "has a version number" do
    expect(EstimateCount::VERSION).not_to be nil
  end

  context "with a MySQL database" do
    before { load_database("mysql")}

    let!(:table) { MySQLTable.create(level: 1) }
    let!(:table_list) { 10_000.times.map { {level: 2} } }
    let!(:table_objects) { MySQLTable.insert_all(table_list) }

    describe ".estimate_count" do
      it "returns the estimated count of records", aggregate_failures: true do
        ActiveRecord::Base.connection.execute("ANALYZE TABLE my_sql_tables")

        scope = MySQLTable.where(level: 2)
        puts scope.estimate_count
        expect(scope.estimate_count).to be_between(9500, 10500) # EXPLAIN
        expect(scope.estimate_count(threshold: 15000)).to eq(10000) # COUNT
      end
    end
  end

  context "with a PostgreSQL database" do
    before { load_database("postgresql") }

    let!(:table) { PostgreSQLTable.create(level: 1) }
    let!(:table_list) { 10_000.times.map { {level: 2} } }
    let!(:table_objects) { PostgreSQLTable.insert_all(table_list) }

    describe ".estimate_count" do
      it "returns the estimated count of records", aggregate_failures: true do
        ActiveRecord::Base.connection.execute("ANALYZE postgre_sql_tables")
        scope = PostgreSQLTable.where(level: 2)
        expect(scope.estimate_count).to eq(10000) # EXPLAIN
        expect(scope.estimate_count(threshold: 15000)).to eq(10000) # COUNT
      end
    end
  end
end
