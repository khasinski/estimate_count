# frozen_string_literal: true

require_relative "../helpers/load_database"

RSpec.describe "EstimateCount Kaminari adapter" do
  before { skip "kaminari is not installed" unless KAMINARI_LOADED }
  before { load_database("postgresql") }

  describe "#estimate_page" do
    it "preloads total_count with the estimate so Kaminari skips COUNT(*)" do
      allow(PostgreSQLTable).to receive(:estimate_count)
        .with(threshold: 1000).and_return(987_654)

      paginated = PostgreSQLTable.estimate_page(1)

      expect(paginated.total_count).to eq(987_654)
    end

    it "applies :per_page when given" do
      allow(PostgreSQLTable).to receive(:estimate_count).and_return(1_000_000)

      paginated = PostgreSQLTable.estimate_page(1, per_page: 50)

      expect(paginated.limit_value).to eq(50)
      expect(paginated.total_count).to eq(1_000_000)
      expect(paginated.total_pages).to eq(20_000)
    end

    it "forwards :threshold to estimate_count" do
      expect(PostgreSQLTable).to receive(:estimate_count)
        .with(threshold: 5_000).and_return(42)

      PostgreSQLTable.estimate_page(1, threshold: 5_000)
    end

    it "computes total_pages from the estimate" do
      allow(PostgreSQLTable).to receive(:estimate_count).and_return(100_000)

      paginated = PostgreSQLTable.estimate_page(1, per_page: 25)

      expect(paginated.total_pages).to eq(4_000)
    end

    it "works on chained scopes" do
      allow(PostgreSQLTable).to receive(:estimate_count)
        .with(threshold: 1000).and_return(321)

      paginated = PostgreSQLTable.where(level: 2).estimate_page(1)

      expect(paginated.total_count).to eq(321)
    end
  end
end
