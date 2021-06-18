class CallEndpointWorker < TaskWorker
  include Sidekiq::Worker

  def perform(task_id, href)
    @task = Task.find(task_id)
    @href = href
    @task.update(calls_started: @task.calls_started + 1)
    response = RestClient.get(url, headers)
    parsed_data = JSON.parse(response)
    Rails.logger.info "write #{parsed_data} to task.outcome"
    #   write_to_file(JSON.pretty_generate(data))
    #   return data
    # rescue RestClient::TooManyRequests
    #   puts("Rate limited while calling #{url}: waiting then trying again")
    #   sleep(0.5)
    #   call_endpoint(href)
  end

  private

  def url
    "#{use_case.host}#{parse_url_params}"
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

  def parse_url_params
    case @href
    when /{&fromDate,toDate}/
      @href.gsub!('{&fromDate,toDate}', "&fromDate=#{start_date}&toDate=#{end_date}")
    when /{&fromTaxYear,toTaxYear}/
      @href.gsub!('{&fromTaxYear,toTaxYear}', "&fromTaxYear=#{start_year}&toTaxYear=#{end_year}&useCase=#{use_case_name}")
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

  def start_date
    @start_date ||= data[:from]
  end

  def end_date
    @end_date ||= data[:to]
  end

  def start_year
    "#{Date.parse(start_date).year - 1}-#{Date.parse(start_date).strftime('%y')}"
  end

  def end_year
    "#{Date.parse(end_date).year - 1}-#{Date.parse(end_date).strftime('%y')}"
  end
end
