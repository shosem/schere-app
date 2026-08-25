class EventGroupSelectionsController < ApplicationController
  before_action :authenticate_user!

  def new
    @groups = current_user.groups
  end

end
