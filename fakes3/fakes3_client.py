import io, requests
import cStringIO

'''
Receives upload requests from local lambda. This client was built to mimic
how the lambda handler will talk to the real s4 server.
'''
class fakes3_client:
	def __init__(self):
		self.endpoint_url = "http://127.0.0.1:10001"

	# get asset from fakes3
	def get_object(self, Bucket, Key):
		asset_url = "{}/{}".format(self.endpoint_url, Key)
		response = requests.get(asset_url)

		## download to local FS from response
		if response.status_code < 300:
			image = cStringIO.StringIO(response.content)
			return {
				"Body": image
			}

	def upload_fileobj(self, Fileobj, Bucket, Key):
		formData = headers = {
			'key': Key
		}

		filetype = Key.split('.')[1]
		
		response = requests.post(
			"{}/{}/{}/".format(self.endpoint_url, Bucket, Key),
			files=[('file', (Key, Fileobj, filetype))],
			data=formData
		)

		if response.status_code < 300:
			print('upload success')
		else:
			print('upload failed')
