class ApiController < ActionController::API
  before_action :doorkeeper_authorize!

  # GET /me.json
  def me
    respond_with current_resource_owner
  end

  private

  # Find the user that owns the access token
  def current_resource_owner
    ServiceAccount.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end
end
