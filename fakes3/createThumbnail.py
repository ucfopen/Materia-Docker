import os, sys#, boto3
from PIL import Image
import PIL.Image

# set environment, either 'dev' or 'prod'
development = True

def resize(image_path, resized_path):
	with Image.open(image_path) as image:
		image.thumbnail(tuple(x / 3 for x in image.size))
		image.save(resized_path)

def handler(event, context):
	for record in event['Records']:
		bucket = record['s3']['bucket']['name']
		key = record['s3']['object']['key']

		if development:
			from fakes3_client import fakes3_client
			s3_client 		= fakes3_client(key)
			resized_path 	= s3_client.resized_path
			download_path 	= s3_client.download_path
			upload_path		= '' # not used, preset
		else:
			s3_client = boto3.client('s3')

		s3_client.download_file(bucket, key, download_path)
		resize(download_path, resized_path)
		asset_path = os.path.split(key)
		s3_client.upload_file(upload_path,
			'{}/thumbnails/{}/'.format(bucket, os.path.split(asset_path[0])[1]), asset_path[1])
