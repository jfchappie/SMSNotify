class QueueMessagesJob < ApplicationJob
  queue_as :default
  
  def perform(job_id, queue, notifications)
    run_recovery = false
    conn = Faraday.new(:headers => { 'Content-Type' => 'application/json'}) do |builder|
      builder.adapter :typhoeus
      builder.response :json, :content_type => /\bjson$/
    end

    notifications.each do |individual|
      response = ""
      data = '{"to_number": "#{individual[:recipient]}","message":"#{job[:message]}", 
              "callback_url":"https://textnotifyapi.herokuapp.com/callback"}'
      conn.in_parallel do
        response = Faraday.post(queue[:url], data)
      end

      if response.status.to_i == 500 
        update_failed_job(individual, JSON.parse(response.body), job_id, queue)
        break
      else
        update_successful_job(individual, JSON.parse(response.body), job_id) 
      end
    end
  end

  private

  def update_successful_job(notify, json_response, job_id)
    Activity.create(action: "job-#{job_id} Success",comments: "number: [#{notify.recipient}] response:#{json_response}")
    response = HashWithIndifferentAccess.new(json_response)
    Notification.where(id: notify.id).update(status: 2, vendor_response_id: response[:message_id])
  end

  def update_failed_job(notify, json_response, job_id, queue)
     Activity.create(action: "job-#{job_id} failure",comments: "number: [#{notify.recipient}] response:#{json_response} que: #{queue.id}")
     if queue.retry_count.to_i < queue.retry_threshold.to_i
      Jobqueue.where(id: queue.id).update(retry_count: queue.retry_count + 1)
    else
      Activity.create(action: "queue-#{queue.id} shutdown",comments: "Error threshold reached.")
      Jobqueue.where(id: queue.id).update(status: 7)
      available_queues = Jobqueue.active.order(retry_count: :asc)
      if available_queues.count > 0
        rescue_queue = available_queues[0]
        Notification.where(job_id: job_id, queue_id: queue.id, status: 0).update_all(queue_id: rescue_queue.id)     
        Activity.create(action: "job-#{job_id} requeue",comments: "que: #{queue.id} moved to: #{rescue_queue.id}")
      else
        raise StandardError.new "No Queue available"
      end 
    end
  end
end
