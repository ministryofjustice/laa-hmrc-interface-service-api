class ApiController < ActionController::API
  before_action :doorkeeper_authorize!
end
