class DashboardController < ApplicationController
  before_filter :authenticate_user!

  def index
    @resources = Resource.where(user_id: current_user.id)
  end

end
