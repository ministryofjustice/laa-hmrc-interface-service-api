class RunSyncTestController < ApplicationController
  def create
    raise 'Unauthorised' unless validate_params

    use_case = UseCase.new(:one)
    time_taken = use_case.run_sync_test(
      @decoded_data.first['first_name'],
      @decoded_data.first['last_name'],
      @decoded_data.first['dob'],
      @decoded_data.first['nino']
    )
    render status: :ok,
           json: {
             success: true,
             message: "ran request data for: #{@decoded_data.first['first_name']} #{@decoded_data.first['last_name']} and it took #{time_taken}"
           }
  rescue RuntimeError
    render json: { errors: ['Not Authenticated'] }, status: :unauthorized
  end

  private

  def validate_params
    validate_access_key && validate_data
  end

  def validate_data
    data_param_present? &&
      data_param_encoded_by_application_user? &&
      decoded_data_matches_schema?
  end

  def data_param_present?
    data_param.present?
  end

  def data_param_encoded_by_application_user?
    decoded_data.present?
  end

  def decoded_data_matches_schema?
    decoded_data.first.keys.sort.eql?(%w[dob first_name from last_name nino to])
  end

  def decoded_data
    @decoded_data ||= JWT.decode(data_param, application_user.secret_key, true, { algorithm: 'HS512' })
  rescue JWT::VerificationError
    false
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
