class PostIndividualMatchingWorker
  include Sidekiq::Worker

  def perform(task_id)
    @task = Task.find(task_id)
    response = RestClient.post(post_url, post_payload, post_headers)
    matching = JSON.parse(response, object_class: OpenStruct)
    Rails.logger.info matching
    # EndpointWorker(task.id, matching._links.individual.href)
  end

  private

  def post_url
    "#{use_case.host}/individuals/matching"
  end

  def post_payload
    {
      firstName: data[:first_name],
      lastName: data[:last_name],
      nino: data[:nino],
      dateOfBirth: data[:dob]
    }.to_json
  end

  def post_headers
    {
      accept: 'application/vnd.hmrc.2.0+json',
      content_type: 'application/json',
      correlationId: @task.id.to_s,
      Authorization: "Bearer #{use_case.bearer_token}"
    }
  end

  def data
    @data ||= @task.data.symbolize_keys
  end

  def use_case
    @use_case ||= UseCase.new(@task.use_case)
  end
end
