module Endpoint
  class Uri
    def initialize(href, **args)
      @href = href
      @options = args
    end

    def for_calling
      case @href
      when /{&fromDate,toDate}/
        @href.gsub!('{&fromDate,toDate}', "&fromDate=#{@options[:from_date]}&toDate=#{@options[:to_date]}")
      when /{&fromTaxYear,toTaxYear}/
        @href.gsub!('{&fromTaxYear,toTaxYear}', "&fromTaxYear=#{tax_years_from}&toTaxYear=#{tax_years_to}")
      else
        @href
      end
    end

    def for_displaying
      Rack::Utils.parse_query(@href).keys[0].gsub(/\?.*/, '').split('/')[2...].join('/')
    end

    private

    def tax_years_from
      tax_years_for(Date.parse(@options[:from_date]))
    end

    def tax_years_to
      tax_years_for(Date.parse(@options[:to_date]))
    end

    def tax_years_for(date)
      year = date.year # set the current year by default
      year -= 1 if date.month < 4 # reduce by a year if the month is pre-april
      financial_year_start = Date.new(year, 4, 1)
      "#{financial_year_start.year}-#{(financial_year_start + 1.year).strftime('%y')}"
    end
  end
end
