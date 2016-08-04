from flask import Flask, request
from util import crossdomain
import requests


# get Lambda handler
from createThumbnail import handler

print handler

app = Flask(__name__)

# s3_endpoint = "http://192.168.99.100:10001/default_bucket"
s3_endpoint = "http://fakes3:10001"

def sendEvent(filename, fd):
	event = {  
	   "Records":[  
	      {  
	         "s3":{  
	            "bucket":{  
	               "name":"fakes3"
	            },
	            "object":{  
	               "key": filename
	               # "key":"HappyFace.jpg",
	            }
	         }
	      }
	   ]
	}

	handler(event, None, fd)



@app.route("/fakes3", methods=["POST"])
@crossdomain(origin='*')
def upload_passthrough():
	headers = dict(request.headers)

	formData = dict(request.form)

	print formData

	file = request.files['file']
	
	print file.mimetype, file.mimetype_params, file.content_type

	print 'firing request'
	print type(file.stream)
	response = requests.post(
		# "http://fakes3:10001/default_bucket", 
		s3_endpoint,
		files=[('file', (file.filename, file.stream, file.content_type))],
		data=formData
	)

	print 'filename', formData['key'], file.filename, file.content_type
	if response.status_code == 201 or response.status_code == 200:
		try:
			sendEvent(formData['key'][0], formData)

		except Exception as e:
			print 'failed to resize image'

		return response.text
	else:
		msg = 'failed to communicate with fakes3 server'
		print msg
		return msg

	# requests.post("http://fakes3:10001/default_bucket")

if __name__ == '__main__':
	app.run(port=10002, host='0.0.0.0')
	# app.run(port=10002)