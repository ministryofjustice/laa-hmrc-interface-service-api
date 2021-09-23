class MainController < ApplicationController
  skip_before_action :doorkeeper_authorize!, only: %i[show]

  def show
    redirect_to rswag_ui_path
  end
end
