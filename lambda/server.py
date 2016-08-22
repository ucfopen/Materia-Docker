from flask import Flask, request, redirect
from util import crossdomain
import requests

# get Lambda handler
from createThumbnail import handler

app = Flask(__name__)

s3_endpoint = "http://fakes3:10001"
get_event = lambda key: {  
   "Records":[  
      {  
         "s3":{  
            "bucket":{  
               "name":"fakes3"
            },
            "object":{
               "key": key
            }
         }
      }
   ]
}

@app.route("/fakes3/<path:key>", methods=["GET"])
@crossdomain(origin='*')
def image_get_redirect(key):
	return redirect("{}/{}".format('http://192.168.99.100:10001/fakes3', key))

@app.route("/fakes3", methods=["POST"])
@crossdomain(origin='*')
def upload_passthrough():
	headers = dict(request.headers)
	formData = dict(request.form) 
	file = request.files['file']

	# passthrough asset post request to s3
	response = requests.post(
		s3_endpoint,
		files=[('file', (file.filename, file.stream, file.content_type))],
		data=formData
	)

	# if that upload was successful, try resizing
	# respond with s3 response either way
	if response.status_code < 300:
		try:
			# edit the event object and send to lambda handler
			event = get_event(formData['key'][0])
			handler(event, None)

		except Exception as e:
			print 'failed to resize image: ', e

		return response.text
	else:
		msg = 'failed to communicate with fakes3 server'
		print msg
		return msg

if __name__ == '__main__':
	app.run(port=10002, host='0.0.0.0')
	# app.run(port=10002)