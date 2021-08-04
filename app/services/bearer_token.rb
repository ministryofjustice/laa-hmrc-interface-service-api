class BearerToken
  USE_CASES = %w[use_case_one use_case_two use_case_three use_case_four].freeze
  def initialize(for_use_case)
    raise 'Unsupported UseCase' unless for_use_case.in?(USE_CASES)

    @credentials = Settings.credentials.send(for_use_case)
  end

  def self.call(for_use_case)
    new(for_use_case).call
  end

  def call
    response = RestClient.post(url, payload)
    parsed_json = JSON.parse(response.body)
    parsed_json['access_token']
  end

  private

  def payload
    {
      grant_type: 'client_credentials',
      client_secret: "#{totp.now}#{@credentials.hmrc_client_secret}",
      client_id: @credentials.hmrc_client_id
    }
  end

  def totp
    ROTP::TOTP.new(@credentials.hmrc_totp_secret,
                   digits: 8,
                   digest: 'sha512',
                   issuer: @credentials.description)
  end

  def url
    "#{@credentials.host}/oauth/token"
  end
end
