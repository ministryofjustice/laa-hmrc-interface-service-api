require "rails_helper"

RSpec.describe ApplicationController do
  include AuthorisedRequestHelper

  controller do
    def index
      head :ok
    end
  end

  it_behaves_like "an unauthorised request"
end
