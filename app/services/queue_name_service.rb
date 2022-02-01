class QueueNameService
  def self.call
    new.call
  end

  def call
    if Settings.sentry.environment == "uat"
      "#{uat_queue_name}-submissions"
    else
      "submissions"
    end
  end

  def uat_queue_name
    branch_name = Settings.status.app_branch
    branch_name.tr(" _/[]().", "-")
  end
end
