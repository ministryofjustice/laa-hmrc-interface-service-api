class Task < ApplicationRecord
  belongs_to :application_user
  enum status: { created: 0, in_progress: 1, completed: 2 }
  enum result: { pending: 0, errored: 1, success: 2, failure: 3 }

  def parse_payload
    mark_as_errored('data_missing') unless data_present?
    return false unless outcome.nil?

    mark_as_errored('encoding_mismatch') unless data_encoded_by_application_user?
    return false unless outcome.nil?

    mark_as_errored('json_schema_mismatch') unless decoded_data_matches_schema?
    return false unless outcome.nil?

    outcome.nil?
  end

  def call
    # needs to start calling the jobs
    in_progress!
    update(outcome: 'Successfully Authenticated, now we would call a service to begin the authentication and ' \
                    'start the tree walking required by the HMRC interactions to request data') # placeholder for uc1controller test
  end

  private

  def mark_as_errored(error_message)
    errored!
    completed!
    update(outcome: { error: error_message })
  end

  def data_present?
    data.present?
  end

  def data_encoded_by_application_user?
    decoded_data.present?
  end

  def decoded_data_matches_schema?
    decoded_data.first.keys.sort.eql?(%w[dob first_name from last_name nino to])
  end

  def decoded_data
    @decoded_data ||= JWT.decode(data, application_user.secret_key, true, { algorithm: 'HS512' })
  rescue JWT::VerificationError
    false
  end
end
