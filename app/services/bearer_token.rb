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
      client_secret: "#{totp.now}#{Settings.credentials.apply.hmrc_client_secret}",
      client_id: Settings.credentials.apply.hmrc_client_id
    }
  end

  def totp
    ROTP::TOTP.new(Settings.credentials.apply.hmrc_totp_secret,
                   digits: 8,
                   digest: 'sha512',
                   issuer: Settings.credentials.apply.description)
  end

  def url
    "#{Settings.credentials.apply.host}/oauth/token"
  end
end
