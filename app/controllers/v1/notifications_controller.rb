class V1::NotificationsController < V1::BaseController
  before_action :authorize_request

  def index
      @notifications = Notification.all
      render json: {notifications: @notifications,status: "ok"}, status: :ok
  end

  def show
      @notifications = Notification.where(job_id: params[:id])
      render json: {notifications: @notifications,status: "ok"}, status: :ok
  end


end
