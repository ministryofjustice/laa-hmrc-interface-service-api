class TaskWorker
  private

  def url
    "#{use_case.host}/individuals/matching"
  end

  def data
    @data ||= @task.data.symbolize_keys
  end

  def use_case
    @use_case ||= UseCase.new(@task.use_case)
  end
end
