# frozen_string_literal: true

require_relative "../helpers/load_database"

RSpec.describe "EstimateCount will_paginate adapter" do
  before { skip "will_paginate is not installed" unless WILL_PAGINATE_LOADED }
  before { load_database("postgresql") }

  describe "#estimate_paginate" do
    it "passes the estimate as :total_entries so will_paginate skips COUNT(*)" do
      allow(PostgreSQLTable).to receive(:estimate_count)
        .with(threshold: 1000).and_return(500_000)

      result = PostgreSQLTable.estimate_paginate(page: 1, per_page: 25)

      expect(result.total_entries).to eq(500_000)
      expect(result.total_pages).to eq(20_000)
    end

    it "honors caller-supplied :total_entries without estimating" do
      expect(PostgreSQLTable).not_to receive(:estimate_count)

      result = PostgreSQLTable.estimate_paginate(page: 1, per_page: 25, total_entries: 999)

      expect(result.total_entries).to eq(999)
    end

    it "forwards :threshold to estimate_count" do
      expect(PostgreSQLTable).to receive(:estimate_count)
        .with(threshold: 5_000).and_return(42)

      PostgreSQLTable.estimate_paginate(page: 1, per_page: 25, threshold: 5_000)
    end

    it "does not mutate the caller's options hash" do
      allow(PostgreSQLTable).to receive(:estimate_count).and_return(100)
      options = { page: 1, per_page: 25, threshold: 2_000 }

      PostgreSQLTable.estimate_paginate(options)

      expect(options).to eq(page: 1, per_page: 25, threshold: 2_000)
    end

    it "works on chained scopes" do
      allow(PostgreSQLTable).to receive(:estimate_count)
        .with(threshold: 1000).and_return(321)

      result = PostgreSQLTable.where(level: 2).estimate_paginate(page: 1, per_page: 10)

      expect(result.total_entries).to eq(321)
    end
  end
end
