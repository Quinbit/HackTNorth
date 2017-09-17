
import SimpleHTTPServer
import SocketServer as socketserver
import os
import threading

class MyHandler(SimpleHTTPServer.SimpleHTTPRequestHandler):
    path_to_image = "imageToSave.png"
    print(path_to_image)
    img = open(path_to_image, 'rb')
    statinfo = os.stat(path_to_image)
    img_size = statinfo.st_size
    print(img_size)

def do_HEAD(self):
    self.send_response(200)
    self.send_header("Content-type", "image/jpg")
    self.send_header("Content-length", img_size)
    self.end_headers()

def do_GET(self):
    self.send_response(200)
    self.send_header("Content-type", "image/jpg")
    self.send_header("Content-length", img_size)
    self.end_headers()
    f = open(path_to_image, 'rb')
    self.wfile.write(f.read())
    f.close()

def do_POST(self):
    # Doesn't do anything with posted data
    content_length = int(self.headers['Content-Length']) # <--- Gets the size of data
    post_data = self.rfile.read(content_length) # <--- Gets the data itself
    print(post_data)
        
    #self._set_headers()
    #self.wfile.write("<html><body><h1>POST!</h1></body></html>")
        
    #vals = post_data.split("_")
    try:
        fh = open("imageToSave.png", "w")
        fh.write(post_data.decode('base64'))
        fh.close()
        results = process_request('en', "imageToSave.png")
            
        return_string = ""
            
        for i in range(len(results)):
            return_string = return_string + "___" + str(results[i]).replace("]","").replace("[","")
    except Exception as e:
        return_string = "en___0"
        print(e)

    self.send_response(200)  # OK
    self.send_header('Content-type', 'text/html')
    self.end_headers()
    self.wfile.write(return_string)


class MyServer(socketserver.ThreadingMixIn, socketserver.TCPServer):
    def __init__(self, server_adress, RequestHandlerClass):
        self.allow_reuse_address = True
        socketserver.TCPServer.__init__(self, server_adress, RequestHandlerClass, False)

if __name__ == "__main__":
    HOST, PORT = "localhost", 9995
    server = MyServer((HOST, PORT), MyHandler)
    server.server_bind()
    server.server_activate()
    server.serve_forever()
    server_thread.start()
