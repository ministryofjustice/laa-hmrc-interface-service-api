class UseCase
  def initialize
    BearerToken.call('apply') unless current_token
  end

  private

  def current_token
    REDIS.get('use_case_1_bearer_token')
  end
end
