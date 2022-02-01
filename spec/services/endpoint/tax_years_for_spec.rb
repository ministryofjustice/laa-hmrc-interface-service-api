require "rails_helper"

RSpec.describe Endpoint::TaxYearsFor do
  subject(:tax_year) { described_class.call(date) }

  context "when the date is at the beginning of April" do
    let(:date) { Date.new(2021, 4, 3) }

    it "returns the previous year to the current year" do
      expect(tax_year).to eql "2020-21"
    end
  end

  context "when the date is past April" do
    let(:date) { Date.new(2021, 5, 3) }

    it "returns the current year to next year" do
      expect(tax_year).to eql "2021-22"
    end
  end
end
