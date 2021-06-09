class SyncTest
  attr_accessor :first_name, :last_name, :date_of_birth, :nino

  def initialize(first_name, last_name, date_of_birth, nino)
    # run with Benchmark.measure { SyncTest.new('first_name', 'last_name', 'date_of_birth(yyyy_mm_dd)', 'nino').call }.real to allow individual details output
    # e.g. Benchmark.measure { SyncTest.new('jagger', 'stafford', '1978-05-28', 'EB268548C').call }.real

    @first_name = first_name
    @last_name = last_name
    @date_of_birth = date_of_birth
    @nino = nino
  end

  def start_date
    '2020-12-01'
  end

  def end_date
    '2021-02-25'
  end

  def start_year
    "#{Date.parse(start_date).year - 1}-#{Date.parse(start_date).strftime('%y')}"
  end

  def end_year
    "#{Date.parse(end_date).year - 1}-#{Date.parse(end_date).strftime('%y')}"
  end

  def use_case
    {
      use_case_one: 'LAA-C1'
    }[@app.to_sym]
  end

  def accept_header(href)
    case href
    when /benefits-and-credits/
      'application/vnd.hmrc.1.0+json'
    else
      'application/vnd.hmrc.2.0+json'
    end
  end

  def parse_params(href)
    case href
    when /{&fromDate,toDate}/
      href.gsub!('{&fromDate,toDate}', "&fromDate=#{start_date}&toDate=#{end_date}")
    when /{&fromTaxYear,toTaxYear}/
      href.gsub!('{&fromTaxYear,toTaxYear}', "&fromTaxYear=#{start_year}&toTaxYear=#{end_year}&useCase=#{use_case}")
    else
      href
    end
  end

  def call_endpoint(href)
    url = "#{@host}#{parse_params(href)}"
    write_to_file("calling #{url}")
    headers = {
      'accept': accept_header(href),
      'correlationId': @correlation_id,
      'Authorization': "Bearer #{@token}"
    }
    response = RestClient.get(url, headers)
    data = JSON.parse(response)
    data = redact_individual(data) if i_should_redact?(data)
    write_to_file(JSON.pretty_generate(data))
    data
  end

  def redact_individual(data)
    data['individual'] = 'redacted'
    data
  end

  def i_should_redact?(data)
    data.keys.include?('individual') && ENV['REDACT'].nil?
  end

  def loop_steps(array)
    array.each do |link|
      puts "  calling #{link}"
      data = call_endpoint(link)
      unless data.to_s.match?(/INTERNAL_SERVER_ERROR/)
        sub_steps = data['_links'].map { |x| x[1]['href'] unless x[0].eql?('self') }.compact
        loop_steps sub_steps if sub_steps.any?
      end
    end
  end

  def write_to_file(data)
    File.open(@filename, 'a') { |file| file.write "#{data}\n"}
  end

  def call
    puts 'get bearer token'
    @app = 'use_case_one'
    bearer = BearerToken.new(@app)
    @token = bearer.call
    @host = Settings.credentials.use_case_one.host
    @correlation_id = SecureRandom.uuid

    puts 'Creating an output file for your data - it will be git ignored'
    Dir.mkdir('user_data') unless Dir.exists?('user_data')
    @filename = "./user_data/#{@first_name}_#{@last_name}.user"
    File.open(@filename, 'w') { |file| file.write "Data for #{@first_name} #{@last_name}\n\n"}

    puts 'POST individuals/Matching'
    post_payload = {
                      "firstName": "#{@first_name}",
                      "lastName": "#{@last_name}",
                      "nino": "#{@nino}",
                      "dateOfBirth": "#{@date_of_birth}"
                    }.to_json
    post_headers = {
                      'accept': 'application/vnd.hmrc.2.0+json',
                      'content_type': 'application/json',
                      'correlationId': @correlation_id.to_s,
                      'Authorization': "Bearer #{@token}"
                    }
    data = RestClient.post("#{@host}/individuals/matching", post_payload, post_headers)
    matching = JSON.parse(data, object_class: OpenStruct)

    puts 'GET matchID'
    data = call_endpoint(matching._links.individual.href)
    next_steps = data['_links'].map { |x| x[1]['href'] unless x[0].eql?('self') }.compact

    puts "Looping through steps from #{matching._links.individual.href}:\n#{next_steps.join("\n")}"
    loop_steps next_steps

    puts "You can read your output file with `cat #{@filename}`"
    puts 'done'
  end
end
