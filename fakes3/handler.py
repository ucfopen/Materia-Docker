import os
import StringIO
import sys
import boto3
from PIL import Image


SESSION = boto3.session.Session()

# When using FakeS3, the Boto configuration variables need to be manipulated
if os.environ['IS_FAKES3'] in ['true', 'True']:
    S3_CLIENT = SESSION.client(
        service_name='s3',
        endpoint_url='http://localhost:10001/',
        aws_access_key_id='secret',
        aws_secret_access_key='secret',
    )
else:
    S3_CLIENT = boto3.client('s3')


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
        output_key = os.environ['OUTPUT_BASE_KEY']
        max_size = os.environ['OUTPUT_MAX_HEIGHT'] + \
            "x" + os.environ['OUTPUT_MAX_WIDTH']
        filename = os.path.basename(source_key)
        base, extension = os.path.splitext(filename)
        extension = extension[1:].upper()

        # If a valid size is not given, output the original
        if not os.environ['OUTPUT_MAX_HEIGHT'] or not os.environ['OUTPUT_MAX_HEIGHT'] or not int(os.environ['OUTPUT_MAX_HEIGHT']) or not int(os.environ['OUTPUT_MAX_WIDTH']):
            output_size = None
        else:
            output_size = int(os.environ['OUTPUT_MAX_HEIGHT']), \
                int(os.environ['OUTPUT_MAX_WIDTH'])

        if extension not in ['JPEG', 'JPG', 'PNG', 'GIF', 'MP3', 'WAV']:
            print "Uploaded file extension is not supported: %s" % extension
            return None

        # Normalize JPEG extensions to match Materia
        if extension == 'JPG':
            extension = 'JPEG'

        uploaded_object = S3_CLIENT.get_object(Bucket=source_bucket,
                                               Key=source_key)

        # Supported audio files are not manipulated
        if extension == 'MP3' or extension == 'WAV':
            audio_output_key = original_output_key = output_key + \
                "/" + base + "." + extension.lower()
            S3_CLIENT.upload_fileobj(Fileobj=uploaded_object["Body"],
                                     Bucket=output_bucket, Key=audio_output_key)
            return

        uploaded_object_body = StringIO.StringIO(
            uploaded_object['Body'].read())

        # No resizing occurs with invalid output sizes
        if not output_size:
            output_key = output_key + "/" + base + "." + extension.lower()
            resized_image_data = _process_image(
                uploaded_object_body, extension, None)

            S3_CLIENT.upload_fileobj(Fileobj=resized_image_data,
                                     Bucket=output_bucket, Key=output_key)
            return

        resized_image_data = _process_image(
            uploaded_object_body, extension, output_size)

        output_key = output_key + "/" + base + \
            "-" + max_size + "." + extension.lower()

        S3_CLIENT.upload_fileobj(Fileobj=resized_image_data,
                                 Bucket=output_bucket, Key=output_key)
