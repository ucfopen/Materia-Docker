import sys, os, re
import time
import logging
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler
from createThumbnail import handler

# Keeps track of the duplicate file registered by filewatcher
duplicateUpload = True

get_event = lambda image_path: {
   "Records":[
      {
         "s3":{
            "bucket":{
               "name":"fakes3"
            },
            "object":{
               "path": image_path
            }
         }
      }
   ]
}

class MyHandler(FileSystemEventHandler):
    def on_created(self, event):
        global duplicateUpload
        # filters all filenames that are alphanumeric and then takes the file
        #   with a length of 5
        uploadedFile = os.path.split(event.src_path)[1]
        if uploadedFile.isalnum() and len(uploadedFile) == 5 and duplicateUpload == True:
            fakes3_event = get_event(event.src_path)
            handler(fakes3_event, None)
            print 'Created!', os.path.split(event.src_path)[1]
            duplicateUpload = not duplicateUpload

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
