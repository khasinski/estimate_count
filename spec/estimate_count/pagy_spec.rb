# frozen_string_literal: true

require_relative "../helpers/load_database"

RSpec.describe "EstimateCount Pagy adapter" do
  before { skip "pagy is not installed" unless PAGY_LOADED }
  before { load_database("postgresql") }

  let(:controller_class) do
    Class.new do
      include Pagy::Backend

      def params
        {}
      end
    end
  end
  let(:controller) { controller_class.new }

  describe "#pagy_estimate" do
    it "injects the estimate as :count so Pagy skips COUNT(*)" do
      allow(PostgreSQLTable).to receive(:estimate_count)
        .with(threshold: 1000).and_return(750_000)

      pagy, _records = controller.pagy_estimate(PostgreSQLTable.all)

      expect(pagy.count).to eq(750_000)
    end

    it "honors caller-supplied :count without estimating" do
      expect(PostgreSQLTable).not_to receive(:estimate_count)

      pagy, _records = controller.pagy_estimate(PostgreSQLTable.all, count: 999)

      expect(pagy.count).to eq(999)
    end

    it "forwards :threshold to estimate_count" do
      expect(PostgreSQLTable).to receive(:estimate_count)
        .with(threshold: 5_000).and_return(42)

      controller.pagy_estimate(PostgreSQLTable.all, threshold: 5_000)
    end

    it "passes other vars (e.g. items) through to pagy" do
      allow(PostgreSQLTable).to receive(:estimate_count).and_return(1_000)

      pagy, _records = controller.pagy_estimate(PostgreSQLTable.all, items: 50)

      expect(pagy.items).to eq(50)
      expect(pagy.count).to eq(1_000)
      expect(pagy.pages).to eq(20)
    end

    it "works on chained scopes" do
      allow(PostgreSQLTable).to receive(:estimate_count)
        .with(threshold: 1000).and_return(321)

      pagy, _records = controller.pagy_estimate(PostgreSQLTable.where(level: 2))

      expect(pagy.count).to eq(321)
    end
  end
end
