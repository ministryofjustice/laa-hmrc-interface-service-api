# :nocov:
class ApplyGetTest
  attr_reader :data

  def initialize(use_case, **args)
    return unless args.keys.difference(%i[first_name last_name nino dob start_date end_date]).empty?

    @use_case = UseCase.new(use_case)
    @data = JSON.parse({
      first_name: args[:first_name],
      last_name: args[:last_name],
      nino: args[:nino],
      dob: args[:dob],
      start_date: args[:start_date],
      end_date: args[:end_date]
    }.to_json, object_class: OpenStruct)
  end

  def self.call(use_case, **args)
    new(use_case, **args).call
  end

  def call(correlation_id: SecureRandom.uuid)
    @correlation_id = correlation_id
    @result = { data: [{ correlation_id: @correlation_id }] }
    data = request_and_extract_data(request_match_id)
    process_next_steps(data)
    @result.to_json
  end

  private

  def process_next_steps(data)
    return if data.to_s.eql?('INTERNAL_SERVER_ERROR')

    next_links = extract_next_links(data)
    loop_each next_links if next_links.any?
  end

  def request_and_extract_data(uri)
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
      data[data.except('_links').keys.first].first
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
    'INTERNAL_SERVER_ERROR' # improve this, hard to do currently as only the live service fails
  end

  def request_match_id
    uri = '/individuals/matching'
    response = RestClient.post("#{host}#{uri}", request_payload, build_headers(uri))
    JSON.parse(response, object_class: OpenStruct)._links.individual.href
  end

  def request_payload
    { firstName: data.first_name, lastName: data.last_name, nino: data.nino, dateOfBirth: data.dob }.to_json
  end

  def extract_next_links(data)
    data['_links'].filter_map { |x| x[1]['href'] unless x[0].eql?('self') }
  end

  def build_uri(uri)
    Endpoint::Uri.new(uri, use_case: @use_case.use_case, from_date: data.start_date, to_date: data.end_date)
  end

  def build_headers(uri)
    Endpoint::Headers.call(uri, @correlation_id, @use_case.bearer_token)
  end

  def host
    @host ||= @use_case.host
  end
end
# :nocov:
