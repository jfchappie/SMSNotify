class JobCreatorService
  attr_reader  :valid, :valid_numbers, :rejected_numbers, :job

  def initialize(params)
    @job = {}
    @job_name = params[:job_name] ? "#{params[:job_name]}-#{Time.now().to_i}" : nil
    @message = params[:message_text]
    @recipients = params[:recipients]
    @group_by = params[:group_by] ? params[:group_by] : 'percent'
    @groups = params[:groups] && params[:groups] < 3 ? params[:groups] : '2'
    @group_split = params[:group_split] ? params[:group_split] : [70,30]
    @rejected_numbers = []
    @valid_numbers = []
    validate_numbers if @recipients
    @valid = @job_name && @message && !@valid_numbers.empty? && !@message.blank? ? true : false
    Jobqueue.update_all(status: 6, retry_threshold: 10, retry_count: 0)
    Activity.create(action: "initialize",comments: "job [#{@job_name}] valid? #{@valid} numbers: #{@valid_numbers.inspect} rejected numbers: #{@rejected_numbers.inspect}")
  end

  def create_job
    @job = Job.create(name: @job_name, message: @message)
    @valid_numbers.each {|num| Notification.create(job_id: @job.id, recipient: num)}
  end

  def assign_queues()
    assign_by_percent()
  end

  def assign_by_percent()
    available_queues = Jobqueue.active.order(percent: :desc).limit(@groups)
    if available_queues.count == 1
        que_id = available_queues[0].id
        Notification.where(job_id: @job.id, queue_id: nil).update_all(queue_id: que_id, status: 0)
    else
      available_queues.each_with_index do |queue, i|
        total_tasks = Notification.where(job_id: @job.id).count  
        tasks_to_que = Float(total_tasks*(@group_split[i].to_i*0.01)).ceil
        Notification.where(job_id: @job.id, queue_id: nil).limit(tasks_to_que).update_all(queue_id: queue.id, status: 0)
      end
    end  
  end

  def execute_queues()
    queues = Jobqueue.active
    if queues
      queues.each do |que|
        notifications = Notification.where(job_id: @job.id, queue_id: que.id)
        QueueMessagesJob.perform_now(@job.id, que, notifications)
      end
    else
      raise StandardError.new "No Queue Available"
    end
  end
  
  def retry_failures()
     until !cleanup_needed(@job.id) do
        cleanup
      end
  end

  private

  def cleanup_needed(job_id)
    Notification.where(job_id: job_id, status: 0).count > 0 &&
    Jobqueue.active.count > 0
  end

  def cleanup()
    Activity.create(action: "cleanup for #{@job.id}",comments: "")
    ques_to_clean = Notification.where(job_id: @job.id).group(:queue_id).pluck(:queue_id)
    ques_to_clean.each do |i|
      queue = Jobqueue.where(id: i)
      queue.each do |q|
        notifications = Notification.where(job_id: @job.id, queue_id: q.id, status: 0)
        QueueMessagesJob.perform_now(@job.id, q, notifications)
      end
     end
  end
  
  def validate_numbers
    @recipients.each do |num|
      clean_num = num.gsub(/\D/, '')
      if clean_num && clean_num.length > 9
        @valid_numbers.append(clean_num)
      else
        @rejected_numbers.append(num)
      end
    end
  end
end
