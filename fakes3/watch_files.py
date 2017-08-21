import os
import re
import time
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler
from handler import upload_thumbnail

is_asset_id = re.compile('\w\-(\w{5})\.')
is_resized = re.compile('\w\-(\w{5})-\w+x\w+.')

# Creates an object that mocks the event object sent to lambda from Fakes3


def get_event(image_key): return {
    "Records": [
        {
            "s3": {
                "bucket": {
                    "name": os.environ['INPUT_BUCKET']
                },
                "object":{
                    "key": image_key
                }
            }
        }
    ]
}


class FileHandler(FileSystemEventHandler):
    def on_created(self, event):
        uploadedFile = os.path.split(event.src_path)[1]
        sizes = os.environ['OUTPUT_MAX_DIMENSIONS']
        sizeArray = sizes.split(',')

        # Creates a relative path to the created file within the filesystem
        image_key = '/'.join(event.src_path.split('/')[-2:])

        if is_asset_id.match(uploadedFile) and not is_resized.match(uploadedFile):
            for size in sizeArray:
                # separates width and height to be used as two separate variables
                currentSize = size.split('x')

                # added to filename to identify size
                os.environ['MAX_SIZE'] = size

                # manipulating environment variables to simulate lambda's multiple environments
                os.environ['OUTPUT_MAX_WIDTH'] = currentSize[0]
                os.environ['OUTPUT_MAX_HEIGHT'] = currentSize[1]

                fakes3_event = get_event(image_key)

                # the handler never has to change because the environment it runs in is changing
                upload_thumbnail(fakes3_event, None)


if __name__ == "__main__":
    path_being_watched = '../s3mnt/fakes3_root/'
    event_handler = FileHandler()
    observer = Observer()
    observer.schedule(event_handler, path_being_watched, recursive=True)
    observer.start()
    try:
        while True:
            # This keeps Materia from running extremely slow
            time.sleep(1)
    except KeyboardInterrupt:
        observer.stop()
    observer.join()
