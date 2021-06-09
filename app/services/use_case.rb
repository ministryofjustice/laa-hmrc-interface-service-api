class UseCase
  def initialize(use_case)
    @use_case = "use_case_#{use_case}"
    BearerToken.call(@use_case) unless current_token
  end

  private

  def current_token
    REDIS.get("#{@use_case}_bearer_token")
  end
end
