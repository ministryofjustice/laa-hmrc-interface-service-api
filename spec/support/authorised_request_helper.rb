module AuthorisedRequestHelper
  def authorise_requests!
    allow(controller).to receive(:doorkeeper_authorize!).and_return(true)
  end

  def access_token
    dk_application.access_tokens.create!
  end

  def dk_application(scopes = %w[use_case_one use_case_two use_case_three use_case_four])
    Doorkeeper::Application.create!(name: 'test', scopes:)
  end
end
