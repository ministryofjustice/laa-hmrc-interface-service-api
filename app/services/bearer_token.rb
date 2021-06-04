class BearerToken
  def self.call
    new.call
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
      client_secret: "#{totp.now}#{Settings.credentials.hmrc_client_secret}",
      client_id: Settings.credentials.hmrc_client_id
    }
  end

  def totp
    ROTP::TOTP.new(Settings.credentials.hmrc_totp_secret,
                   digits: 8,
                   digest: 'sha512',
                   issuer: Settings.credentials.description)
  end

  def url
    "#{Settings.credentials.host}/oauth/token"
  end
end
