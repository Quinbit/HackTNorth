#!/usr/bin/env python
"""
    Very simple HTTP server in python.
    Usage::
    ./dummy-web-server.py [<port>]
    Send a GET request::
    curl http://localhost
    Send a HEAD request::
    curl -I http://localhost
    Send a POST request::
    curl -d "foo=bar&bin=baz" http://localhost
    """

from googletrans import Translator
import json
import ast
from operator import itemgetter
from os.path import join, dirname
from os import environ
from watson_developer_cloud import *

from BaseHTTPServer import BaseHTTPRequestHandler, HTTPServer
import SocketServer
    
def process_request(lang, imageUrlNS):
    cutoff_score = 0.6
    entries_to_keep = 3
    language = str(lang)
    imageUrl = str(imageUrlNS)
    # Define packages
    translator = Translator()
    visual_recognition = VisualRecognitionV3('2016-05-20', api_key='9a7a0b69bd17b6170aea8d075a67a431b1890107')
    
    # Raw response data as string
    response = json.dumps(visual_recognition.classify(images_url=imageUrl), indent=2)
    
    # Stripped response data with classes
    array = ast.literal_eval(response).get('images', 0)[0].get('classifiers', 1)[0].get('classes', 2)
    
    # Classes ordered by score (highest first)
    ordered = sorted(array, key=itemgetter('score'), reverse = True)
    # Only keep classes with scores higher than cutoff_scor
    filtered = [it for it in ordered if it['score'] > cutof_score]
    
    # Only keep top entries_to_keep entries
    top = filtered[:entries_to_keep]
    
    # List of all expressions in English
    eng = [expression['class'] for expression in top]
    
    # List of all translated objects
    translated = translator.translate(eng, dest=language)
    
    # return translated text + pronunciation for all relevant entries
    return [[str(i.text), str(i.pronunciation)] for i in translated]

class S(BaseHTTPRequestHandler):
    def _set_headers(self):
        self.send_response(200)
        self.send_header('Content-type', 'text/html')
        self.end_headers()
    
    def do_GET(self):
        self._set_headers()
        self.wfile.write("<html><body><h1>hi!</h1></body></html>")
    
    def do_HEAD(self):
        self._set_headers()
    
    def do_POST(self):
        # Doesn't do anything with posted data
        content_length = int(self.headers['Content-Length']) # <--- Gets the size of data
        post_data = self.rfile.read(content_length) # <--- Gets the data itself
        print(post_data)
        
        #self._set_headers()
        #self.wfile.write("<html><body><h1>POST!</h1></body></html>")

        vals = post_data.split("_")
        try:
            results = process_request(vals[0], vals[1])

            return_string = ""

            for i in range(len(results)):
                return_string = return_string + "___" + str(results[i]).replace("]","").replace("[","")
        except:
            return_string = "en___0"
        
        self.send_response(200)  # OK
        self.send_header('Content-type', 'text/html')
        self.end_headers()
        self.wfile.write(return_string)



def run(server_class=HTTPServer, handler_class=S, port=80):
    server_address = ('', port)
    httpd = server_class(server_address, handler_class)
    print 'Starting httpd...'
    httpd.serve_forever()

if __name__ == "__main__":
    from sys import argv
    
    if len(argv) == 2:
        run(port=int(argv[1]))
    else:
        run()