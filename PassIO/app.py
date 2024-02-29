import time

import redis
from flask import Flask, render_template
from flask_pymongo import PyMongo

app = Flask(__name__)
app.config['MONGO_URI'] = 'mongodb://localhost:5000/passio_db'
mongo = PyMongo(app)
app.debug = True
cache = redis.Redis(host='redis', port=6379)


@app.route('/')
def home():
    return render_template('home.html')


@app.route('/events')
def events():
    return render_template('events.html')


@app.route('/about')
def about():
    return render_template('about.html')


if __name__ == '__main__':
    app.run(debug=True)
