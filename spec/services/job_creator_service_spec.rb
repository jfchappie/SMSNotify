require 'rails_helper'

RSpec.describe JobCreatorService, type: :model do
  
  it 'should be valid with proper params' do
    params = {job_name: 'Sample Job', message_text: 'test message', recipients: ['555-555-5555','6666666666','777 777-7777','abc', '334455']}
    job = JobCreatorService.new(params)
    expect(job.valid).to eq(true)
    expect(job.valid_numbers).to eq(["5555555555", "6666666666", "7777777777"])
    expect(job.rejected_numbers).to eq(["abc", "334455"])
  end
  
  it 'should be invalid with proper params but not numbers' do
    params = {}
    job = JobCreatorService.new(params)
    expect(job.valid).to eq(false)
    expect(job.valid_numbers).to eq([])
    expect(job.rejected_numbers).to eq([])
  end

 it 'should be invalid with proper params and all invalid numbers' do
    params = {job_name: 'Sample Job', message_text: 'test message', recipients: ['777-7777','abc', '334455']}
    job = JobCreatorService.new(params)
    expect(job.valid).to eq(false)
    expect(job.valid_numbers).to eq([])
    expect(job.rejected_numbers).to eq(["777-7777", "abc", "334455"])
  end
 
  it 'should be invalid with no message' do
    params = {job_name: 'Sample Job', message_text: '', recipients: ['555-555-5555','6666666666','777 777-7777','abc', '334455']}
    job = JobCreatorService.new(params)
    expect(job.valid).to eq(false)
    expect(job.valid_numbers).to eq(["5555555555", "6666666666", "7777777777"])
    expect(job.rejected_numbers).to eq(["abc", "334455"])
  end

 it 'should create unassigned notifications' do
    params = {job_name: 'Sample Job', message_text: '', recipients: ['555-555-5555','6666666666','777 777-7777','abc', '334455']}
    @job = JobCreatorService.new(params)
    @job.create_job
    expect(Notification.where(job_id: @job.job[:id], queue_id: nil).count).to eq(3)
 end
 it 'notifications should all be assigned' do
    Jobqueue.create(name: "first q", status: 6)
    Jobqueue.create(name: "second q", status: 6)
    params = {job_name: 'Sample Job', message_text: '', recipients: ['555-555-5555','6666666666','777 777-7777','abc', '334455']}
    @job = JobCreatorService.new(params)
    @job.create_job
    expect(Notification.all.where(job_id: @job.job[:id], queue_id: nil).count).to eq(3)
    @job.assign_queues
    expect(Notification.where(job_id: @job.job[:id], queue_id: nil).count).to eq(0)
 end

end
