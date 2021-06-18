class CallEndpointWorker < TaskWorker
  include Sidekiq::Worker

  def perform(task, href)
    @task = task
    @href = href
    response = RestClient.get(url, headers)
    parsed_data = JSON.parse(response)
    #   write_to_file(JSON.pretty_generate(data))
    #   return data
    # rescue RestClient::TooManyRequests
    #   puts("Rate limited while calling #{url}: waiting then trying again")
    #   sleep(0.5)
    #   call_endpoint(href)
  end

  private

  def url
    "#{use_case.host}/individuals/matching"
  end

  def headers
    {
      accept: accept_header,
      correlationId: @task.id.to_s,
      Authorization: "Bearer #{use_case.bearer_token}"
    }
  end

  def accept_header
    case @href
    when /benefits-and-credits/
      'application/vnd.hmrc.1.0+json'
    else
      'application/vnd.hmrc.2.0+json'
    end
  end

  def parse_params
    case @href
    when /{&fromDate,toDate}/
      @href.gsub!('{&fromDate,toDate}', "&fromDate=#{data[:from]}&toDate=#{data[:to]}")
    when /{&fromTaxYear,toTaxYear}/
      @href.gsub!('{&fromTaxYear,toTaxYear}', "&fromTaxYear=#{data[:from]}&toTaxYear=#{data[:to]}&useCase=#{use_case_name}")
    else
      @href
    end
  end

  def use_case_name
    {
      one: 'LAA-C1',
      two: 'LAA-C2',
      three: 'LAA-C3',
      four: 'LAA-C4'
    }[@task.use_case]
  end
end
