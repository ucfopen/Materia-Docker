import os
from fakes3_client import fakes3_client
from PIL import Image
import sys
import StringIO

s3_client = fakes3_client()


def _process_image(image, extension, resize=None):
    image = Image.open(image)
    image_data = StringIO.StringIO()

    if resize:
        image.thumbnail(resize)

    image.save(image_data, extension)
    image.close()

    # image.save is not seeking to beginning of buffer upon completion this is a manual reset
    image_data.seek(0)

    return image_data


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
        max_size = os.environ['OUTPUT_MAX_HEIGHT'] + \
            "x" + os.environ['OUTPUT_MAX_WIDTH']
        output_size = int(os.environ['OUTPUT_MAX_HEIGHT']), \
            int(os.environ['OUTPUT_MAX_WIDTH'])
        output_key = os.environ['OUTPUT_BASE_KEY']

        filename = os.path.basename(source_key)
        base, extension = os.path.splitext(filename)
        extension = extension[1:].upper()

        if extension not in ['JPEG', 'JPG', 'PNG', 'GIF', 'MP3', 'WAV']:
            print "Uploaded file extension is not supported: %s" % extension
            return None

        if extension == 'JPG':
            extension = 'JPEG'

        # Download the image from s3 into memory
        uploaded_object = s3_client.get_object(Bucket=source_bucket,
                                               Key=source_key)

        if extension == 'MP3' or extension == 'WAV':
            audio_output_key = original_output_key = output_key + \
                "/" + base + "." + extension.lower()
            s3_client.upload_fileobj(Fileobj=uploaded_object["Body"],
                                     Bucket=output_bucket, Key=audio_output_key)
            return

        # body is a file like object
        uploaded_object_body = uploaded_object['Body']

        if(os.environ['OUTPUT_ORIGINAL']):
            original_image_data = _process_image(
                uploaded_object_body, extension)

            original_output_key = output_key + "/" + base + "." + extension.lower()

            s3_client.upload_fileobj(Fileobj=original_image_data,
                                     Bucket=output_bucket, Key=original_output_key)

        resized_image_data = _process_image(
            uploaded_object_body, extension, output_size)

        resized_output_key = output_key + "/" + base + \
            "-" + max_size + "." + extension.lower()

        s3_client.upload_fileobj(Fileobj=resized_image_data,
                                 Bucket=output_bucket, Key=resized_output_key)
