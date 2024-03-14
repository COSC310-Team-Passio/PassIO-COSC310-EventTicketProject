import redis
from flask import Flask, render_template
from flask_pymongo import PyMongo

app = Flask(__name__)
app.config["MONGO_URI"] = "mongodb+srv://passio:passio@passioatlas.foiwof6.mongodb.net/passio_db?retryWrites=true&w=majority"
mongo = PyMongo(app)
app.debug = True
cache = redis.Redis(host='redis', port=6379)

@app.route('/')
def home():
    mongo.db.host.insert_one({"name": "venue 1", "address 1": "3430 big valley street, MA"})
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

@app.route('/checkout')
def checkout():
    return render_template('checkout.html')

@app.route('/admin')
def admin():
    return render_template('admin.html')

@app.route('/search')
def search():
    return render_template('search.html')

@app.route('/customerProfile')
def customerprofile():
    return render_template('customerProfile.html')

if __name__ == '__main__':
    app.run(debug=True)
