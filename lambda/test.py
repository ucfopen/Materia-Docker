from flask import Flask, request
from util import crossdomain
import requests

# get Lambda handler
from createThumbnail import handler

print handler

app = Flask(__name__)

s3_endpoint = "http://192.168.99.100:10001/default_bucket"

def sendEvent(filename, fd):
	event = {  
	   "Records":[  
	      {  
	         "s3":{  
	            "bucket":{  
	               "name":"default_bucket"
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



@app.route("/default_bucket", methods=["POST"])
@crossdomain(origin='*')
def upload_passthrough():
	headers = dict(request.headers)

	formData = dict(request.form)

	file = request.files['file']
	# del params['file']

	# print file

	print 'firing request'
	print type(file.stream)
	response = requests.post(
		# "http://fakes3:10001/default_bucket", 
		s3_endpoint,
		files=[('file', (file.filename, file.stream, file.content_type))],
		data=formData
	)

	print 'filename', formData['key']
	if response.status_code == 201 or 200:
		sendEvent(formData['key'][0], formData)
	else:
		print 'some error'
	return response.text

	# requests.post("http://fakes3:10001/default_bucket")

if __name__ == '__main__':
	# app.run(port=10002, host='0.0.0.0')
	app.run(port=10002)