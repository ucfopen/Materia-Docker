import os, sys, uuid
from PIL import Image
import PIL.Image

# set environment, either 'dev' or 'prod'
ENV = 'dev'

def resize(image_path):
	print 'path', image_path
	#os.rename(image_path + '/.fakes3_metadataFFF/content', image_path + '/.fakes3_metadataFFF/content.png')
	with Image.open(image_path + '/.fakes3_metadataFFF/content') as image:
		image.thumbnail(tuple(x / 3 for x in image.size))

		base_path = os.path.split(image_path)[0]
		base_filename = os.path.split(image_path)[1]
		resized_filename = "/thumb/resized-" + base_filename
		resized_path = base_path + resized_filename

		image.save(resized_path, 'png')

def handler(event, context):
	for record in event['Records']:
		bucket = record['s3']['bucket']['name']
		uploaded_image = record['s3']['object']['path']

		resize(uploaded_image)
