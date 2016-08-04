import boto3, os, sys, uuid
from PIL import Image
import PIL.Image

# set environment, either 'dev' or 'prod'
ENV = 'dev'

def resize(image_path, resized_path):
	with Image.open(image_path) as image:
		image.thumbnail(tuple(x / 3 for x in image.size))
		image.save(resized_path)

def handler(event, context):
	for record in event['Records']:
		bucket = record['s3']['bucket']['name']
		key = record['s3']['object']['key'] 

		if ENV == 'dev':
			from fakes3_client import fakes3_client
			s3_client 		= fakes3_client(key)
			resized_path 	= s3_client.resized_path
			download_path 	= s3_client.download_path
			upload_path		= '' # not used, preset

		if ENV == 'prod':
			s3_client = boto3.client('s3')
			print s3_client.meta.endpoint_url

		s3_client.download_file(bucket, key, download_path)
		resize(download_path, resized_path)
		s3_client.upload_file(upload_path, '{}resized'.format(bucket), key)
		