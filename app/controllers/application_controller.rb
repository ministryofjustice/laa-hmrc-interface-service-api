class ApplicationController < ActionController::API
  before_action :doorkeeper_authorize!

  ERROR_MAPPINGS = {
    ActionController::ParameterMissing => :bad_request,
    Errors::ContractError => :unprocessable_entity
  }.freeze

  # :nocov:
  # TO DO: nocov added because this isn't implemented
  # in a controller yet, but it should be!
  ERROR_MAPPINGS.each do |klass, status|
    rescue_from klass do |error|
      render json: { error: }, status: status
    end
  end
  # :nocov:
end
