import time
import redis
from flask import *
from flask_pymongo import PyMongo
from user import *

app = Flask(__name__)
app.config["MONGO_URI"] = ("mongodb+srv://passio:passio@passioatlas.foiwof6.mongodb.net/passio_db?retryWrites=true&w"
                           "=majority")
mongo = PyMongo(app)
app.debug = True
cache = redis.Redis(host='redis', port=6379)

CurrentUser = None

users = mongo.db.Users.find({})
for user in users: 
    print(user)

@app.route('/')
def home():
    # mongo.db.host.insert_one({"name": "Venue for Ants", "address": "I know where you live"})
    return render_template('index.html')

# @app.route('/index')
# def index():
#     return render_template('index.html')

@app.route('/styleguide')
def styleguide():
    return render_template('styleguide.html')

@app.route('/events')
def events():
    return render_template('events.html')

@app.route('/events_submit', methods = ["POST"]) #This is throwing an error currently
def events_submit():
    name = request.form.get('e_name')
    location = request.form.get('e_location')
    description = request.form.get('e_description')
    artist = request.form.get('e_artist')
    genre = request.form.get('e_genre')
    verified = request.form.get('e_verified')
    mongo.db.Event.insert_one({'name': name, 'location': location, 'description': description, 'artist': artist, 'genre': genre, 'verified': verified})
    return render_template('evententry.html')

@app.route('/events_entry')
def events_entry():
    return render_template('evententry.html')

@app.route('/events_display', methods = ["GET"])
def events_display():
    all_events = mongo.db.Event.find()
    return render_template('events.html', events=all_events) #pass all events into html to be used in for loop in html

@app.route('/loginandregister')
def loginRegister():
    return render_template('loginandregister.html')

@app.route('/login', methods=["POST"])
def login():
    email = request.form.get('lemail')
    password = request.form.get('lpassword')
    haKey = request.form.get('lhostadminkey')
    
    logSuccess = None
    logIssue = None
    
    condition1 = mongo.db.Users.find_one({"email": email})
    condition2 = mongo.db.Users.find_one({"email": email, "password": password})
    condition3 = mongo.db.Users.find_one({"email": email, "password": password, "special key": haKey})
    
    global CurrentUser
    uName = condition3["name"]
    
    if condition3:
        # Change these from the TestAdminKey to the actual collection that they are stored
        if mongo.db.TestAdminKey.find_one({"host key": haKey}):
            print("user is a host")
            
            CurrentUser = Host(uName, email, haKey, ["dummy", "data", "for now"])
        elif mongo.db.TestAdminKey.find_one({"admin key": haKey}):
            print("user is an admin")
            # Initialize global CurrentUser here
            CurrentUser = Admin(uName, email, haKey)
        else:
            print("user is an attendee")
            # Initialize global CurrentUser here
            CurrentUser = Attendee(uName, email)
            
        logSuccess = True
        logIssue = ""
        
    elif condition2:
        logSuccess = False
        logIssue = "Incorrect host/admin key. Leave blank if you don't have one"
    elif condition1:
        logSuccess = False
        logIssue = "Incorrect password"
    else:
        logSuccess = False
        logIssue = "No user found under: "+email
    
    # Probably will go back to the home page and give a little "successfully registered/logged in instead"
    # Failed login would not change the page
    return render_template('loginandregister.html', loginStatus=uName, loginIssue=logIssue)

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


@app.route('/customerProfile')
def customerprofile():
    return render_template('customerProfile.html')


@app.route('/update_profile', methods=['POST'])
def update_profile():
    # Get info from form
    name = request.form.get('firstName')
    email = request.form.get('email')
    password = request.form.get('password')

    print('debug line below')
    print(name, email, password)

    name = 'jared'
    email = 'jared@jared.com'
    password = 'password'

    # Send data to db
    mongo.db.Users.insert_one({
        'name': name,
        'email': email,
        'password': password
    })

    # Get data from db
    user = mongo.db.Users.find_one({
        'name': name,
        'email': email,
        'password': password
    })


    app.logger.debug(f"Debug line - info sent to db: {name}, {email}, {password}")
    app.logger.debug(f"Debug line - info returned from db: {user}")

    print('user below')
    print(user)

    # Flash a message containing user info
    # flash(f"Profile Updated: {name}, {email}", 'info')

    return redirect('/index')


@app.route('/host')
def host():
    users = mongo.db.User.find({})
    for user in users: 
        app.logger.debug(user)
    return render_template('host.html')

if __name__ == '__main__':
    app.run(debug=True)