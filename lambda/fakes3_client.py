import io, requests

class fakes3_client:
	def __init__(self, key):
		self.endpoint_url = "http://fakes3:10001"
		self.key = key

		pathsplit = key.split('/')
		self.basepath = '/'.join(pathsplit[:-1])
		self.filename = pathsplit[-1]

		# save everything as jpg for testing, just cuz
		self.download_path = '{}.jpg'.format(self.filename)
		self.resized_path = 'resize-'+self.download_path

	# get asset from fakes3
	def download_file(self, bucket, key, download_path):
		asset_url = "{}/{}".format(self.endpoint_url, self.key)
		response = requests.get(asset_url)

		## download to LFS from response
		if response.status_code < 300:
			with open(self.download_path, 'wb') as f:
				f.write(response.content)
		else:
			print('download request failed')

	def upload_file(self, upload_path, filename, key):
		new_key = '{}/thumb/{}'.format(self.basepath, self.filename)
		print(new_key)
		with open(self.resized_path, 'rb') as f:
			stream = io.BytesIO(f.read())
			formData = headers = {
				'key': new_key
			}
			response = requests.post(
				# "http://fakes3:10001/default_bucket", 
				self.endpoint_url,
				files=[('file', (filename, stream, 'png'))],
				data=formData
			)
			if response.status_code < 300:
				print('upload success')
			else:
				print('upload request failed')