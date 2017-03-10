import os
from fakes3_client import fakes3_client
from PIL import Image
import sys
import StringIO

s3_client = fakes3_client()

def upload_thumbnail(event, context):
	'''
	RESPONDS TO FakeS3 EVENTS FROM BUCKET PUT
	Retrieves file, checks format, resizes, uploads resized to target
	'''
	for record in event['Records']:
		source_bucket = record['s3']['bucket']['name']
		source_key = record['s3']['object']['key']

		# build up the output variables
		output_bucket = os.environ['OUTPUT_BUCKET']
		output_base_key = os.environ['OUTPUT_BASE_KEY']
		output_size = int(os.environ['OUTPUT_MAX_HEIGHT']), \
			int(os.environ['OUTPUT_MAX_WIDTH'])

		filename = os.path.basename(source_key)
		base, extension = os.path.splitext(filename)
		extension = extension[1:].upper()

		if extension not in ['JPEG', 'JPG', 'PNG', 'GIF']:
			print "Uploaded file extension is not supported: %s" % extension
			return None

		if extension == 'JPG':
			extension = 'JPEG'

		# Download the image from s3 into memory
		uploaded_object = s3_client.get_object(Bucket=source_bucket,
											   Key=source_key)

		# body is a file like object
		uploaded_object_body = uploaded_object['Body']

		image = Image.open(uploaded_object_body)

		image.thumbnail(output_size)
		resized_image_data = StringIO.StringIO()

		image.save(resized_image_data, extension)
		image.close()

		# image.save is not seeking to beginning of buffer upon completion
        # this is a manual reset
		resized_image_data.seek(0)

		output_key = output_base_key+filename
		s3_client.upload_fileobj(Fileobj=resized_image_data,
                                 Bucket=output_bucket, Key=output_key)
