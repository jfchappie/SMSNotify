class V1::JobsController < V1::BaseController
  before_action :authorize_request

  def index
      @jobs = Job.all
      render json: {jobs: @jobs,status: "ok"}, status: :ok
  end
  
end
