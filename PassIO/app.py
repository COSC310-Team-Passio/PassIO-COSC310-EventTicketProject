import time
import redis
from flask import *
from flask_pymongo import PyMongo

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
@app.route('/events_create', methods = ["POST"])
def events_create():
    name = request.form.get('e_name')
    location = request.form.get('e_location')
    description = request.form.get('e_description')
    artist = request.form.get('e_artist')
    genre = request.form.get('e_genre')
    mongo.db.Event.insert_one({'name': name, 'location': location, 'description': description, 'artist': artist,  'genre': genre})
    return render_template('eventEntry.html', confirm=name)

@app.route('/event_entry')
def event_entry():
    return render_template('eventEntry.html')

@app.route('/about')
def about():
    return render_template('about.html')

@app.route('/loginandregister')
def loginRegister():
    return render_template('loginandregister.html')

@app.route('/login', methods=["POST"])
def login():
    email = request.form.get('lemail')
    password = request.form.get('lpassword')
    haKey = request.form.get('lhostadminkey')
    logSuccess = None

    condition1 = mongo.db.Users.find_one({"email": email, "special key": haKey})
    condition2 = mongo.db.Users.find_one({"email": email, "password": password, "special key": haKey})
    
    if condition1 and not condition2:
        logSuccess = True
    elif mongo.db.Users.find_one({"email": email, "password": password, "special key": haKey}):
        logSuccess = True
    else:
        email = "Rip bozo not in the db"
        logSuccess = False
    
    # Probably will go back to the home page and give a little "successfully registered/logged in instead"
    # Failed login would not change the page
    return render_template('loginandregister.html', confirmText=email)

@app.route('/register', methods=["POST"])
def register():
    email = request.form.get("remail")
    name = request.form.get("name")
    password = request.form.get("rpassword")
    haKey = request.form.get("rhostadminkey")
    regSuccess = None
    
    if mongo.db.Users.find_one({"email": email}):
        regSuccess = False
        print("user already exists, invalid email")
    else:
        if mongo.db.TestAdminKey.find_one({"admin key:": haKey}):
            print("handle giving user admin privileges")
            mongo.db.Users.insert_one({"email": email, "name": name, "password": password, "special key": haKey})
            regSuccess = True
        elif mongo.db.TestAdminKey.find_one({"host key:": haKey}):
            print("handle giving appropriate host privileges and add")
            mongo.db.Users.insert_one({"email": email, "name": name, "password": password, "special key": haKey})
            regSuccess = True
        else:
            haKey = ""
            mongo.db.Users.insert_one({"email": email, "name": name, "password": password, "special key": haKey})
            regSuccess = True
            
    # Probably will go back to the home page and give a little "successfully registered/logged in instead"
    return render_template('loginandregister.html', regSuccess=regSuccess)

@app.route('/checkout')
def checkout():
    return render_template('checkout.html')

@app.route('/admin')
def admin():
    return render_template('admin.html')

@app.route('/search')
def search():
    return render_template('search.html')

if __name__ == '__main__':
    app.run(debug=True)