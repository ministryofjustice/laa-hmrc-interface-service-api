class MainController < ApplicationController
  skip_before_action :doorkeeper_authorize!, only: %i[show]

  def show
    render json: hello_world_struct
  end

  private

  def hello_world_struct
    {
      success: true,
      message: 'Hello World'
    }
  end
end
