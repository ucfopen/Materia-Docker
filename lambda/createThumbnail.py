from __future__ import print_function
import boto3, os, sys, uuid, shutil
from PIL import Image
import PIL.Image
import requests
import io

s3_client = boto3.client('s3')
print(s3_client.meta.endpoint_url)

# s3_endpoint = "http://192.168.99.100:10001/default_bucket"
s3_endpoint = "http://fakes3:10001"

def resize(image_path, resized_path):
	with Image.open(image_path) as image:
		image.thumbnail(tuple(x / 3 for x in image.size))
		image.save(resized_path)

def process_image(key, fd):
	# get asset from fakes3
	asset_url = "{}/{}".format(s3_endpoint, key)
	r = requests.get(asset_url)

	## download to LFS from response
	pathsplit = key.split('/')
	filename = pathsplit[-1]
	basepath = '/'.join(pathsplit[:-1])
	download_path = '{}.png'.format(filename)
	if r.status_code < 300:
		with open(download_path, 'wb') as f:
			f.write(r.content)
	else:
		print('request failed')

	resized_path = 'resize-'+download_path
	# here's the actual lambda
	resize(download_path, resized_path)

	new_key = '{}/thumb/{}'.format(basepath, filename)
	print(new_key)
	with open(resized_path, 'rb') as f:
		stream = io.BytesIO(f.read())
		formData = headers = {
			'key': new_key
		}
		response = requests.post(
			# "http://fakes3:10001/default_bucket", 
			s3_endpoint,
			files=[('file', (filename, stream, 'png'))],
			data=formData
		)
		# res = requests.post(s3_endpoint, data=f)
		print(response)
	# s3_client.upload_file(upload_path, '{}resized'.format(bucket), key)


def handler(event, context, fd):
	for record in event['Records']:
		bucket = record['s3']['bucket']['name']
		key = record['s3']['object']['key'] 
		process_image(key, fd)

		# s3_client.download_file(bucket, key, download_path)
		# resize(download_path, 'resize-'+download_path)
		# s3_client.upload_file(upload_path, '{}resized'.format(bucket), key)
		