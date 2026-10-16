class ErrorsController < ApplicationController
  layout "error"

  def show
    @exception = request.env["action_dispatch.exception"]
    @status_code = ActionDispatch::ExceptionWrapper.new(
      request.env, @exception
    ).status_code

    render view_for_code(@status_code), status: @status_code
  end

  private

    def view_for_code(code)
      if code == 404
        "404"
      else
        "500"
      end
    end
end
