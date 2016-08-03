from flask import Flask, request
from util import crossdomain
import requests

# get Lambda handler
from createThumbnail import handler

print handler

app = Flask(__name__)

def sendEvent(filename):
	event = {  
	   "Records":[  
	      {  
	         "s3":{  
	            "bucket":{  
	               "name":"mybucket"
	            },
	            "object":{  
	               "key": filename
	               # "key":"HappyFace.jpg",
	            }
	         }
	      }
	   ]
	}

	handler(event, None)

@app.route("/default_bucket", methods=["POST"])
@crossdomain(origin='*')
def upload_passthrough():
	headers = dict(request.headers)

	formData = dict(request.form)

	file = request.files['file']
	# del params['file']

	# print file

	print 'firing request'
	response = requests.post(
		# "http://fakes3:10001/default_bucket", 
		"http://192.168.99.100:10001/default_bucket",
		files=[('file', (file.filename, file.stream, file.content_type))],
		data=formData
	)

	return response.text

	# requests.post("http://fakes3:10001/default_bucket")

if __name__ == '__main__':
	app.run(port=10002, host='0.0.0.0')
	# app.run(port=10002)