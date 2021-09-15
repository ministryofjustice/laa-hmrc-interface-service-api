module Endpoint
  class TaxYearsFor
    attr_accessor :date

    def initialize(date)
      @date = date
    end

    def self.call(date)
      new(date).call
    end

    def call
      year = date.year # set the current year by default
      year -= 1 if date_is_pre_april_6th # reduce by a year if the month is pre-april-6th
      financial_year_start = Date.new(year, 4, 1)
      "#{financial_year_start.year}-#{(financial_year_start + 1.year).strftime('%y')}"
    end

    private

    def date_is_pre_april_6th
      date.month < 4 || (date.month.eql?(4) && date.day < 6)
    end
  end
end
