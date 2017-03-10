import os, re
import time
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler
from handler import upload_thumbnail

is_asset_id = re.compile('\w\-(\w{5})\.')

# Creates an object that mocks the event object sent to lambda from Fakes3
get_event = lambda image_key: {
   "Records":[
      {
         "s3":{
            "bucket":{
               "name":"fakes3"
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
        # Creates a relative path to the created file within the filesystem
        image_key = '/'.join(event.src_path.split('/')[-3:])
        # Makes sure a thumbnail of a thumbnail is not being created.
        is_thumb = image_key.find('thumbnails') != -1
        if is_asset_id.match(uploadedFile) and not is_thumb:
            fakes3_event = get_event(image_key)
            upload_thumbnail(fakes3_event, None)

if __name__ == "__main__":
    path_being_watched = '../s3mnt/fakes3_root/'
    event_handler = FileHandler()
    observer = Observer()
    observer.schedule(event_handler, path_being_watched, recursive=True)
    observer.start()
    try:
        while True:
            #This keeps Materia from running extremely slow
            time.sleep(1)
    except KeyboardInterrupt:
        observer.stop()
    observer.join()
