from flask import Flask
import requests
app = Flask(__name__)

instance_id_url = "http://169.254.169.254/latest/meta-data/instance-id"

@app.route("/")
def hello_world():
   return "Hello, World!"

@app.route("/id")
def get_instance_id():
    instance_id = requests.get(instance_id_url).content.decode('utf-8')
    return "Instance id - {}".format(instance_id)

if __name__ == "__main__":
   app.run(host="0.0.0.0", port=5001)
