class MainController < ApplicationController
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
