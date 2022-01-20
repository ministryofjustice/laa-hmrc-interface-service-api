module SubmissionProcessable
  extend ActiveSupport::Concern

  private

  def process_next_steps(data)
    return if data.to_s.eql?('INTERNAL_SERVER_ERROR')

    next_links = extract_next_links(data)
    loop_each next_links if next_links.any?
  end

  def request_and_extract_data(uri)
    sleep(Settings.delay) # Having a fraction of a second pause reduces the instances of rate limiting that occur
    parsed_uri = build_uri(uri)
    data = request_endpoint(parsed_uri.for_calling)
    extract_data_from(data, parsed_uri)
    data
  end

  def loop_each(array_of_urls)
    array_of_urls.each do |uri|
      data = request_and_extract_data(uri)
      process_next_steps(data)
    end
  end

  def extract_data_from(data, parsed_uri)
    if data.to_s.eql?('INTERNAL_SERVER_ERROR')
      record_error_data(parsed_uri)
    elsif data_is_valid?(data)
      record_valid_data(data, parsed_uri)
    end
  end

  def data_is_valid?(data)
    (data.is_a?(Array) || data.is_a?(Hash)) && data.except('_links').keys.present?
  end

  def record_valid_data(data, parsed_uri)
    key = build_data_key(data, parsed_uri)
    value = build_data_value(data)
    @result[:data] << { "#{key}": value }
  end

  def record_error_data(parsed_uri)
    @result[:data] << { "#{parsed_uri.for_displaying}": 'returned INTERNAL_SERVER_ERROR' }
  end

  def build_data_value(data)
    if data.is_a?(Hash)
      data[data.except('_links').keys.first]
    else
      # :nocov:
      # is this required? (it doesn't seem to be getting called,
      # I am not sure what sort of data structure it would apply to?)
      data[data.except('_links').keys.first].first
      # :nocov:
    end
  end

  def build_data_key(data, parsed_uri)
    [parsed_uri.for_displaying, data.except('_links').keys.first].join('/').tr('-', '_')
  end

  def request_endpoint(uri)
    response = RestClient.get("#{host}#{uri}", Endpoint::Headers.call(uri, @correlation_id, @use_case.bearer_token))
    JSON.parse(response)
  rescue RestClient::TooManyRequests
    Rails.logger.info "Rate limited while calling #{uri}: waiting then trying again"
    sleep(0.33)
    request_endpoint(uri)
  rescue RestClient::InternalServerError, RestClient::NotFound
    'INTERNAL_SERVER_ERROR' # TODO: improve this, hard to do currently as only the live service fails
  end

  def request_match_id
    uri = '/individuals/matching'
    response = RestClient.post("#{host}#{uri}", request_payload, build_headers(uri))
    JSON.parse(response).dig('_links', 'individual', 'href')
  rescue RestClient::ExceptionWithResponse => e
    raise Errors::CitizenDetailsMismatchError, 'User details not matched' if response_code(e, 'MATCHING_FAILED')
  end

  def request_payload
    {
      firstName: submission.first_name,
      lastName: submission.last_name,
      nino: submission.nino,
      dateOfBirth: submission.dob
    }.to_json
  end

  def extract_next_links(data)
    data['_links'].filter_map { |x| x[1]['href'] unless x[0].eql?('self') }
  end

  def build_uri(uri)
    Endpoint::Uri.new(uri, use_case: @use_case.use_case, from_date: submission.start_date, to_date: submission.end_date)
  end

  def build_headers(uri)
    Endpoint::Headers.call(uri, @correlation_id, @use_case.bearer_token)
  end

  def host
    @host ||= @use_case.host
  end

  def response_code(error, text)
    JSON.parse(error.response.body)['code'].match(/#{text}/)
  end
end
