import time
import redis
from flask import *
from flask_pymongo import PyMongo
from bson.objectid import *
from user import *
#from ticket import *

app = Flask(__name__)
app.secret_key = '938472637656'
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
    tickets = mongo.db.Event.insert_one({'name': name, 'location': location, 'description': description, 
                                         'artist': artist, 'genre': genre, 
                                         'verified': "false"})
    #generateTickets(tickets['event_id'], 2, 29.99)  -- use this line after the event has been approved
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
@app.route('/eventapproval')
def eventapproval():
    unapproved_events = mongo.db.Event.find({"verified": "false"})
    return render_template('eventapproval.html',user=CurrentUser, unapproved_events=unapproved_events)
@app.route('/editevent')
def editevent():
    event_id = request.args.get('id')  # Get event ID from query parameter
    if event_id:
        event = mongo.db.Event.find_one({"_id": ObjectId(event_id)})
        if event:
            return render_template('editevent.html', event=event)
    return redirect(url_for('events'))

@app.route('/update_event', methods=['POST'])
def update_event():
    event_id = request.form.get('event_id')
    if event_id:
        updated_data = {
            'name': request.form.get('name'),
            'location': request.form.get('location'),
            'artist': request.form.get('artist'),
            'genre': request.form.get('genre'),
            'description': request.form.get('description'),
        }
        mongo.db.Event.update_one({'_id': ObjectId(event_id)}, {'$set': updated_data})
        flash('Event updated successfully.', 'success')
        return redirect(url_for('events'))
    flash('Failed to update event.', 'error')
    return redirect(url_for('editevent', id=event_id))


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
            unapproved_events = mongo.db.Event.find({"verified": "false"})
            CurrentUser.special_key = special_key
            return render_template('customerprofile.html', user=CurrentUser, unapproved_events=unapproved_events)
        elif special_key == "host":
            CurrentUser = Host(user["name"], email, special_key, [])
            CurrentUser.special_key = special_key
        else:
            CurrentUser = Attendee(user["name"], email)

        # Redirect to a dashboard or profile page
        return redirect(url_for('customerprofile'))
    else:
        logSuccess = False
        logIssue = "No user found under: "+email
    
    # Probably will go back to the home page and give a little "successfully registered/logged in instead"
    # Failed login would not change the page
    if logSuccess:
        return redirect(url_for('events'))
    else:
        return render_template('loginandregister.html', loginIssue=logIssue)


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
    if CurrentUser == None:
        return render_template('loginandregister.html')
    numTickets = request.args.get('numTickets',0)
    numTickets = min(max(int(numTickets), 1), 5) # Acts as Math.clamp would in other languages
    event_id = request.args.get('event_id')
    event_id = ObjectId(event_id)
    ticketQuery = {"event_id": event_id, "user_id": ""}
    ticketQuery = mongo.db.Ticket.find(ticketQuery)
    tickets = []
    total = 0
    for i in range(0, numTickets):
        try:
            t = ticketQuery[i]
            tickets.append({"_id":str(t['_id']), "price":t['price'], "seat_number":t['seat_number'], "event_id":str(t['event_id']), "user_id":None})
            total += t['price']
        except IndexError:
            break
    session['t'] = tickets
    return render_template('checkout.html', tickets=tickets, total=total, event_id=event_id, numTickets=numTickets)

@app.route('/purchase', methods=["POST"])
def purchase():
    #TODO put the form input names in, or don't maybe, we really only need the one
    fName = request.args.get(""); lName = request.args.get("")
    address1 = request.args.get(""); address2 = request.args.get("") 
    province = request.args.get(""); postalCode = request.args.get("")
    
    ccName = request.args.get(""); ccNum = request.args.get("cc-number")
    ccExpiration = request.args.get(""); ccCVV = request.args.get("")
    
    tickets = session.pop('t', None)
    if tickets is None:
        print("no available tickets")
        return redirect(url_for('events'))
        # Go back to events? idk, the only time this would happen is if there were no valid tickets for the checkout function to list
    # Process valid card details but like we're really just checking the card number
    #TODO 
    #if ccNum is valid # The credit card checking algorithm probably needs its own function, and I don't want to go find out what it is right now and it also doesn't matter as much as the rest of this loop
    if True: # the if ccNum is valid check would replace this if statement
        targetUserId = mongo.db.Users.find_one({"email":CurrentUser.email})['_id']
        for t in tickets:
            mongo.db.Ticket.find_one_and_replace({'_id':ObjectId(t['_id'])}, 
                                                {"_id":ObjectId(t['_id']), "price":t['price'],
                                                 "seat_number":t['seat_number'], "event_id":ObjectId(t['event_id']), 
                                                 "user_id":targetUserId})
        return('purchase_success.html') # maybe we just go back to the main page with a purchase complete message instead
    else:
        return(purchase_failure.html)

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
        user_info = mongo.db.Users.find_one({"email": CurrentUser.email})
        if user_info.get("special key") == "admin":
            unapproved_events = mongo.db.Event.find({"verified": "false"})
            return render_template('customerprofile.html', user=CurrentUser, unapproved_events=unapproved_events)
        elif user_info:
            return render_template('customerprofile.html', user=user_info)
        else:
            flash("User information not found.", "error")
            return render_template(url_for('loginandregister'), error="User information not found.")
    else:
        flash("You must be logged in to view this page.", "info")
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
    if CurrentUser is not None and CurrentUser.special_key == "admin":
        event_id = request.form.get('event_id')
        mongo.db.Event.update_one({'_id': ObjectId(event_id)}, {'$set': {'verified': 'verified'}})
        flash('Event approved successfully.', 'success')
        return redirect(url_for('eventapproval'))
    else:
        flash('You do not have permission to perform this action.', 'error')
        return redirect(url_for('customerprofile'))


if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5001)