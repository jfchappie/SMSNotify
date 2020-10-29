# SMSNotification API

This is a demo project that will test load balancing SMS messages between several services.

# Authentication

This is a secure API that requires an access token.  To obtain an access token send a login request such as:

Request:

curl --location --request POST '<domain>/auth/login?email=<email>&password=<password>' -H 'Accept: application/vnd.textnotify.com; version=1'

Response:

{
   "token":"<your token>",
   "exp":"10-30-2020 20:20",
   "username":"<your display name>"
}

# Sending Messages

Required fields:

job_name - A user friendly name identifying this request,  
recipients - A list of one or more phone numbers to send the message to.  Numbers need to be 8 digits minimum
message_text - The message you want to send

Optional fields:

groups - The number of job queues to create.  
group_split - how to split the load [70,30], in this case 70% to the first queue and 30% to the second.

Note: groups can be 1 or 2, if 1 then 100% will be sent to the first queue and the group_split will be ignored.


Request:

curl POST '<domain>/messages' -H 'Accept: application/vnd.textnotify.com; version=1' -H 'Authorization: Bearer <token>' --header "Content-Type: application/json" --data '{"job_name":"Sample Job", "recipients":[ "222-333-4444","555-555-5555"], "message_text":"sample message"}' 
  
Response:

A uniqe id identifying this job.

exmple:

{
   "job_id":41
}
  
If a phone number is provided that does not meet the requirements, that number will be returned as well, however if any valid numbers are provided the job will run without the invalid numbers.

example:

{
   "rejected":[
      "abc",
      "334455"
   ],
   "job_id":41
}
# Jobs

get a list of all available jobs

request:

 $ curl -X GET '<domain>/jobs' -H 'Accept: application/vnd.textnotify.com; version=1' -H 'Authorization: Bearer <token>' --header "Content-Type: application/json"
  
response:

{
   "jobs":[
      {
         "id":1,
         "name":"Sample Job",
         "message":"sample message",
         "created_at":"2020-10-26T20:03:56.781Z",
         "updated_at":"2020-10-26T20:03:56.781Z"
      },
     ...
      {
         "id":42,
         "name":"Sample Job-1604007121",
         "message":"sample message",
         "created_at":"2020-10-29T21:32:01.176Z",
         "updated_at":"2020-10-29T21:32:01.176Z"
      }
   ],
   "status":"ok"
}

# Notifications

get a list of notifications by job

request:

curl -X GET '<domain>/notifications/<job_id>' -H 'Accept: application/vnd.textnotify.com; version=1' -H 'Authorization: Bearer <token>' -H "Content-Type: application/json"

response:
{
   "notifications":[
      {
         "id":397,
         "job_id":40,
         "recipient":"2223334444",
         "queue_id":1,
         "vendor_response_id":"c437b45b-8f2e-4ed0-8bb5-842c1711a0b1",
         "status":"5",
         "created_at":"2020-10-28T23:00:10.226Z",
         "updated_at":"2020-10-28T23:00:11.383Z"
      },
      ...
      {
         "id":410,
         "job_id":40,
         "recipient":"9878767653",
         "queue_id":2,
         "vendor_response_id":"99cd246b-9a31-41df-8749-8f3912b95609",
         "status":"5",
         "created_at":"2020-10-28T23:00:10.476Z",
         "updated_at":"2020-10-28T23:00:15.739Z"
      }
   ],
   "status":"ok"
}
