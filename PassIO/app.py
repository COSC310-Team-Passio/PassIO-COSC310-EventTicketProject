import time
import redis
from flask import *
from flask_pymongo import PyMongo
from bson.objectid import *
from user import *
#from ticket import *

app = Flask(__name__)
app.config["MONGO_URI"] = ("mongodb+srv://passio:passio@passioatlas.foiwof6.mongodb.net/passio_db?retryWrites=true&w"
                           "=majority")
mongo = PyMongo(app)
app.debug = True
cache = redis.Redis(host='redis', port=6379)

CurrentUser = None

#users = mongo.db.Users.find({})
#for user in users: 
#   print(user)
#@app.route('/index')
#def index():
#   return render_template('index.html')
#@app.route('/styleguide')
#def styleguide():
#   return render_template('styleguide.html')

#@app.route('/')
#def home():
    # mongo.db.host.insert_one({"name": "Venue for Ants", "address": "I know where you live"})
#    return reroute()

# @app.route('/index')
# def index():
#     return render_template('index.html')
@app.route('/')
@app.route('/events')
def events():
    all_events = mongo.db.Event.find()
    return render_template('events.html', events=all_events) #pass all events into html to be used in for loop in html

# USING TEST VARIABLES FOR TICKET CREATION WE SHOULD PROBABLY ADD OPTIONS FOR TICKET PRICE AND EVENT CAPACITY
@app.route('/events_submit', methods = ["POST"]) #This is throwing an error currently
def events_submit():
    name = request.form.get('e_name')
    location = request.form.get('e_location')
    description = request.form.get('e_description')
    artist = request.form.get('e_artist')
    genre = request.form.get('e_genre')
    verified = request.form.get('e_verified')
    tickets = mongo.db.Event.insert_one({'name': name, 'location': location, 'description': description, 
                                         'artist': artist, 'genre': genre, 
                                         'verified': verified})
    generateTickets(tickets['event_id'], 2, 29.99)
    return render_template('evententry.html')

def generateTickets(eventID, capacity:int, price:float):
    tickets = []
    for i in range(0, capacity):
        tickets.append({"price": price, "user_id":"", "event_id": eventID, "seat_number":i})
    mongo.db.Ticket.insert_many(tickets)
    return

@app.route('/events_entry')
def events_entry():
    return render_template('evententry.html')

@app.route('/hostEntry')
def hostentry():
    return render_template('hostEntry.html')

@app.route('/loginandregister')
def loginRegister():
    return render_template('loginandregister.html')


@app.route('/login', methods=["POST"])
def login():
    email = request.form.get('lemail')
    password = request.form.get('lpassword')

    found_user = mongo.db.Users.find_one({"email": email, "password": password})

    if found_user:
        # Basic user details
        name = found_user.get("name", "User")
        global CurrentUser

        # Role-based access control
        if found_user.get("special key") == "admin":
            print("User is an admin")
            CurrentUser = Admin(name, email)
        elif found_user.get("special key") == "host":
            print("User is a host")
            CurrentUser = Host(name, email)
        else:
            print("User is an attendee")
            CurrentUser = Attendee(name, email)

        return redirect(url_for('customerprofile'))
    else:
        logIssue = "Incorrect email or password"
        return render_template('loginandregister.html', loginIssue=logIssue)


@app.route('/register', methods=["POST"])
def register():
    email = request.form.get("remail")
    name = request.form.get("name")
    password = request.form.get("rpassword")
    haKey = request.form.get("rhostadminkey")
    regSuccess = None
    global CurrentUser
    CurrentUser = None

    if mongo.db.Users.find_one({"email": email}):
        regSuccess = False
        print("user already exists, invalid email")
    else:
        if mongo.db.TestAdminKey.find_one({"admin key:": haKey}):
            print("handle giving user admin privileges")
            mongo.db.Users.insert_one({"email": email, "name": name, "password": password, "special key": haKey})
            regSuccess = True
            CurrentUser = Admin(name, email, haKey)
        elif mongo.db.TestAdminKey.find_one({"host key:": haKey}):
            print("handle giving appropriate host privileges and add")
            mongo.db.Users.insert_one({"email": email, "name": name, "password": password, "special key": haKey})
            regSuccess = True
            CurrentUser = Host(name, email, haKey, ["dummy", "data", "for now"])
        else:
            haKey = ""
            mongo.db.Users.insert_one({"email": email, "name": name, "password": password, "special key": haKey})
            regSuccess = True
            CurrentUser = Attendee(name, email)
            
    # Probably will go back to the home page and give a little "successfully registered/logged in instead"
    return render_template('customerprofile.html', regSuccess=regSuccess)


@app.route('/checkout')
def checkout():
    event_id = request.args.get('event_id')
    event_id = ObjectId(event_id)
    ticketQuery = {"event_id": event_id, "user_id": ""}
    ticketQuery = mongo.db.Ticket.find(ticketQuery)
    tickets = []
    total = 0
    for t in ticketQuery:
         tickets.append({"price":t['price'], "seat_number":t['seat_number'], "event_id":t['event_id'], "user_id":t['user_id']})
         total += t['price']
    return render_template('checkout.html', tickets=tickets, total=total)

@app.route('/')


@app.route('/admin')
def admin():
    return render_template('admin.html')


@app.route('/search', methods=['GET', 'POST'])
def search():
    if request.method == 'POST':
        # Get the search term from search bar
        search_term = request.form['search_term'].strip() # Trim whitespaces

        # Build the query based on search term
        query = {
            "$or": [
                { "name": { "$regex": f".*{search_term}.*", "$options": "i" } },
                { "location": { "$regex": f".*{search_term}.*", "$options": "i" } },
                { "description": { "$regex": f".*{search_term}.*", "$options": "i" } },
                { "artist": { "$regex": f".*{search_term}.*", "$options": "i" } },
                { "genre": { "$regex": f".*{search_term}.*", "$options": "i" } } 
            ]
        }
        # Fetch results from db
        results = mongo.db.Event.find(query)
        
        return render_template('events.html', events=results)
        
    return render_template('search.html')


@app.route('/customerprofile')
def customerprofile():
    if CurrentUser is not None:
        # Assuming CurrentUser.email is the email of the logged-in user
        user_info = mongo.db.Users.find_one({"email": CurrentUser.email})
        if user_info:
            # Pass the user_info to the template
            return render_template('customerprofile.html', user=user_info)
        else:
            flash("User information not found.", "error")
            # User info not found, handle accordingly (e.g., redirect or show an error message)
            return render_template(url_for('loginandregister'), error="User information not found.")
    else:
        flash("You must be logged in to view this page.", "info")
        # No user is logged in, redirect to login page
        return redirect(url_for('loginRegister'))


@app.route('/update_profile', methods=['POST'])
def update_profile():
    current_user_email = CurrentUser.email

    name = request.form.get('name')
    email = request.form.get('email')
    username = request.form.get('username')

    update = {
        '$set': {
            'name': name,
            'email': email,
            'username': username
        }
    }
    if email and email != current_user_email:
        CurrentUser.email = email

    CurrentUser.name = name
    CurrentUser.username = username
    mongo.db.Users.update_one({'email': current_user_email}, update)

    return redirect('/customerprofile')

@app.route('/logout', methods=['GET', 'POST'])
def logout():
    # Your logic to handle logout, e.g., clearing the CurrentUser or session
    global CurrentUser
    CurrentUser = None
    # Redirect to home page or login page after logout
    return redirect('/')

@app.route('/host')
def host():
    users = mongo.db.User.find({})
    for user in users: 
        app.logger.debug(user)
    return render_template('host.html')

@app.context_processor
def inject_user():
    return dict(CurrentUser=CurrentUser)

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5001)