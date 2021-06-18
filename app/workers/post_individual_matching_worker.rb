class PostIndividualMatchingWorker < TaskWorker
  include Sidekiq::Worker

  def perform(task_id)
    @task = Task.find(task_id)
    response = RestClient.post(url, post_payload, post_headers)
    matching = JSON.parse(response, object_class: OpenStruct)
    Rails.logger.info matching
    # EndpointWorker(task.id, matching._links.individual.href)
    @task.update(calls_completed: 1)
  end

  private

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
end
