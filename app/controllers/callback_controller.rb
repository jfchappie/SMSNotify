class CallbackController < ApplicationController
  def create
    Notification.where(vendor_response_id: params[:message_id]).update(status: 5)
    render json: "Success", status: :ok
  end
end
