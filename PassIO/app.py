import time
import redis
from flask import Flask, render_template
from flask_pymongo import PyMongo
from databaseTest import *

app = Flask(__name__)
app.config["MONGO_URI"] = "mongodb+srv://passio:passio@passioatlas.foiwof6.mongodb.net/passio_db?retryWrites=true&w=majority"
mongo = PyMongo(app)
app.debug = True
cache = redis.Redis(host='redis', port=6379)

@app.route('/')
def home():
    # mongo.db.host.insert_one({"name": "Venue for Ants", "address": "I know where you live"})
    return render_template('home.html')

@app.route('/index')
def index():
    return render_template('index.html')

@app.route('/styleguide')
def styleguide():
    return render_template('styleguide.html')

@app.route('/events')
def events():
    return render_template('events.html')

@app.route('/about')
def about():
    return render_template('about.html')

@app.route('/KayceeTest')
def KayceeTest():
    return render_template('KayceeTest.html')

@app.route("/forward/", methods=["POST"])
def move_forward():
    print("Thing so I know I can do code stuff")
    notification()
    forward_message = "Moving Forward..."
    return render_template("KayceeTest.html", forward_message=forward_message)

if __name__ == '__main__':
    app.run(debug=True)