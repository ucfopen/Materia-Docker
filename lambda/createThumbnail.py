from __future__ import print_function
import boto3, os, sys, uuid, shutil
from PIL import Image
import PIL.Image
import requests
import io

s3_client = boto3.client('s3')
print(s3_client.meta.endpoint_url)

s3_endpoint = "http://192.168.99.100:10001/default_bucket"

def resize_image(image_path, resized_path):
	with Image.open(image_path) as image:
		image.thumbnail(tuple(x / 2 for x in image.size))
		image.save(resized_path)
	 
def handler(event, context, fd):
	for record in event['Records']:
		bucket = record['s3']['bucket']['name']
		key = record['s3']['object']['key'] 
		# download_path = '/tmp/{}{}'.format(uuid.uuid4(), key)
		download_path = key
		# upload_path = '/tmp/resized-{}'.format(key)
		upload_path = 'thumb-{}'.format(key)

		# s3_client.download_file(bucket, key, download_path)
		r = requests.get("{}/{}".format(s3_endpoint, key))
		download_path = '{}.png'.format(key.split('/')[-1])
		if r.status_code == 200:
			with open(download_path, 'wb') as f:
				f.write(r.content)
		else:
			print('request failed')

		resize_image(download_path, 'resize-'+download_path)

		with open('resize-'+download_path, 'rb') as f:
			stream = io.BytesIO(f.read())
			fd['key'] = 'somenewkey'
			response = requests.post(
				# "http://fakes3:10001/default_bucket", 
				s3_endpoint,
				files=[('file', ('bullshit', stream, 'png'))],
				data=fd
			)
			# res = requests.post(s3_endpoint, data=f)
			print(response)
		# s3_client.upload_file(upload_path, '{}resized'.format(bucket), key)
		