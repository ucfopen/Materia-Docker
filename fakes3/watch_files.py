import sys, os, re
import time
import logging
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler
from createThumbnail import handler

is_asset_id = re.compile('^\w{5}\.\w*?$')

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

class MyHandler(FileSystemEventHandler):
    def on_created(self, event):
        # filters all filenames that are alphanumeric and then takes the file
        #   with a length of 5
        uploadedFile = os.path.split(event.src_path)[1]
        image_key = '/'.join(event.src_path.split('/')[-3:])
        if is_asset_id.match(uploadedFile):
            print 'saw file change', image_key
            fakes3_event = get_event(image_key)
            handler(fakes3_event, None)

if __name__ == "__main__":
    path = '../s3mnt/fakes3_root/fakes3/uploads/'
    event_handler = MyHandler()
    observer = Observer()
    observer.schedule(event_handler, path, recursive=True)
    observer.start()
    try:
        while True:
            time.sleep(1)
            print "Watching " + path
    except KeyboardInterrupt:
        observer.stop()
    observer.join()
