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

@app.route('/')
@app.route('/events')
def events():
    all_events = mongo.db.Event.find({"verified": "verified"})
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

    user = mongo.db.Users.find_one({"email": email, "password": password})
    if user:
        special_key = user.get("special key", "")
        global CurrentUser
        if special_key == "admin":
            CurrentUser = Admin(user["name"], email, special_key)
            CurrentUser.special_key = special_key
        elif special_key == "host":
            CurrentUser = Host(user["name"], email, special_key, [])
            CurrentUser.special_key = special_key
        else:
            CurrentUser = Attendee(user["name"], email)

        # Redirect to a dashboard or profile page
        return redirect(url_for('customerprofile'))
    else:
        # Handle login failure
        return render_template('loginandregister.html', error="Invalid credentials")


@app.route('/register', methods=["POST"])
def register():
    email = request.form.get("remail")
    name = request.form.get("name")
    password = request.form.get("rpassword")

    if mongo.db.Users.find_one({"email": email}):
        # User already exists
        return render_template('loginandregister.html', regIssue="User already exists with this email.")
    else:
        # Insert new user
        user_data = {
            "email": email,
            "name": name,
            "password": password,
            "special key": ""
        }
        mongo.db.Users.insert_one(user_data)
        # Set the global CurrentUser based on the role derived from special_key
        global CurrentUser
        CurrentUser = Attendee(name, email)

        # Redirect to profile page with success message
        return redirect(url_for('customerprofile', regSuccess=True))


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

@app.route('/approve_event', methods=['POST'])
def approve_event():
    if CurrentUser and CurrentUser.speicalkey == "admin":
        event_id = request.form.get('event_id')
        mongo.db.Event.update_one(
            {'_id': ObjectId(event_id)},
            {'$set': {'verified': True}}
        )
        # Redirect to some page with a message that the event was approved
        return redirect(url_for('admin_dashboard', message="Event approved."))
    else:
        # Redirect to login page or display an error if the user is not an admin
        return redirect(url_for('loginRegister', error="You do not have permission to approve events."))


if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5001)