class V1::MessagesController < V1::BaseController
  before_action :authorize_request

  def create
    @event = JobCreatorService.new(msg_params)
    if @event.valid
      @event.create_job
      @event.assign_queues
      @event.execute_queues
      @event.retry_failures
      render json: {rejected: @event.rejected_numbers,job_id:  @event.job[:id]}, status: :ok
    else
      render json: "Invalid Request",status: :unprocessable_entity
    end
  end

  def msg_params
    params.require(:message).permit(:job_name, :message_text, :groups, :group_by, :group_split => [], :recipients => [])
  end
end
