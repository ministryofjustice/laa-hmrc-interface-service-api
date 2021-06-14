class UseCaseOneController < ApplicationController
  def create
    raise 'Unauthorised' unless validate_params

    task = application_user.tasks.create(data: data_param, use_case: :one)
    return render status: :forbidden unless task.parse_payload

    render status: :ok,
           json: {
             success: true,
             message: task.outcome
           }
  rescue RuntimeError
    render json: { errors: ['Not Authenticated'] }, status: :unauthorized
  end

  private

  def validate_params
    validate_access_key
  end

  def validate_access_key
    key_is_present? && application_user_exists? && application_user_has_permission?
  end

  def application_user_exists?
    application_user.present?
  end

  def application_user_has_permission?
    application_user.use_cases.include?(1)
  end

  def application_user
    @application_user ||= ApplicationUser.find_by(access_key: access_key_param)
  end

  def key_is_present?
    access_key_param.present?
  end

  def access_key_param
    request.headers['Authorization']
  end

  def data_param
    return nil if params[:data].blank?

    @data_param ||= params.require(:data)
  end
end
