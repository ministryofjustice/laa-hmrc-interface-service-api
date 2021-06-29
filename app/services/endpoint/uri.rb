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
      TaxYearsFor.call(Date.parse(@options[:from_date]))
    end

    def tax_years_to
      TaxYearsFor.call(Date.parse(@options[:to_date]))
    end
  end
end
