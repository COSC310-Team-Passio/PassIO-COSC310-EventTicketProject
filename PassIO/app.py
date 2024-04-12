import redis
from flask import *
from flask_pymongo import PyMongo
from bson.objectid import *
from user import *
from datetime import datetime

app = Flask(__name__)
app.secret_key = '938472637656'
app.config["MONGO_URI"] = ("mongodb+srv://passio:passio@passioatlas.foiwof6.mongodb.net/passio_db?retryWrites=true&w"
                           "=majority")
mongo = PyMongo(app)
app.debug = True
cache = redis.Redis(host='redis', port=6379)

CurrentUser = None


@app.route('/')
def home():
    all_events = mongo.db.Event.find({"verified": "verified"})
    return render_template('index.html', events=all_events)


@app.route('/events_submit', methods=["POST"])  # This is throwing an error currently
def events_submit():
    name = request.form.get('e_name')
    location = request.form.get('e_location')
    description = request.form.get('e_description')
    artist = request.form.get('e_artist')
    genre = request.form.get('e_genre')
    event_date_str = request.form.get('e_date')
    event_date = datetime.strptime(event_date_str, '%Y-%m-%d') if event_date_str else None
    num_tickets = int(request.form.get('e_tickets', 0))
    ticket_price = float(request.form.get('e_price'))
    eventObj = mongo.db.Event.insert_one({
        'name': name,
        'location': location,
        'description': description,
        'artist': artist,
        'genre': genre,
        'event_date': event_date,  # Ensure your MongoDB is set to store dates correctly
        'num_tickets': num_tickets,
        'ticket_price': ticket_price,
        'verified': 'false',
        'cancelled': False,
        'host': CurrentUser.email
    })
    #Moving this to purchase time
    return render_template('myevents.html')


def generateTickets(eventId: ObjectId, userId: ObjectId, numTickets: int):
    tickets = []
    event = mongo.db.Event.find_one({"_id": eventId})
    if not event:
        flash("Event does not exist.", 'error')
        return

    maxTickets = event['num_tickets']
    currentTickets = mongo.db.Ticket.count_documents({"event_id": eventId})

    # Check if there are enough tickets available to fulfill this purchase.
    if currentTickets >= maxTickets:
        flash("Event is sold out", 'error')
        return

    for i in range(currentTickets, min(currentTickets + numTickets, maxTickets)):
        tickets.append({"user_id": userId, "event_id": eventId, "seat_number": i})

    if tickets:
        mongo.db.Ticket.insert_many(tickets)
    else:
        flash("No tickets generated.", "error")


@app.route('/events_entry')
def events_entry():
    return render_template('evententry.html')


@app.route('/hostEntry')
def hostentry():
    return render_template('hostEntry.html')


@app.route('/loginandregister')
def loginRegister():
    return render_template('loginandregister.html')


@app.route('/eventDetails')
def evenDetail():
    event_id = request.args.get('id')  # Get event ID from query parameter
    if event_id:
        event = mongo.db.Event.find_one({"_id": ObjectId(event_id)})
        if event:
            return render_template('eventDetails.html', event=event)
    return redirect(url_for('index'))


@app.route('/eventapproval')
def eventapproval():
    unapproved_events = mongo.db.Event.find({"verified": "false"})
    return render_template('eventapproval.html', user=CurrentUser, unapproved_events=unapproved_events)


@app.route('/editevent', methods=['POST'])
def editevent():
    event_id = request.form.get('event_id')  # Get event ID from hidden filed
    if event_id:
        event = mongo.db.Event.find_one({"_id": ObjectId(event_id)})
        if event:
            return render_template('editevent.html', event=event)
    return redirect(url_for('events'))


@app.route('/hostEvents')
def hostEvents():
    host_events = mongo.db.Event.find({'host': CurrentUser.email})
    host_events = list(host_events)
    return render_template('hostEvents.html', user=CurrentUser, host_events=host_events)


@app.route('/update_event', methods=['POST'])
def update_event():
    event_id = request.form.get('event_id')
    if event_id:
        # Convert event_date from string to datetime object
        event_date_str = request.form.get('date')
        event_date = datetime.strptime(event_date_str, '%Y-%m-%d')

        updated_data = {
            'name': request.form.get('name'),
            'location': request.form.get('location'),
            'artist': request.form.get('artist'),
            'genre': request.form.get('genre'),
            'description': request.form.get('description'),
            'event_date': event_date,
            'num_tickets': int(request.form.get('num_tickets')),
            'ticket_price': float(request.form.get('price')),
            'verified': 'false'
        }

        # Update the event in the database
        mongo.db.Event.update_one(
            {'_id': ObjectId(event_id)},
            {'$set': updated_data}
        )

        flash('Event updated successfully.', 'success')
        return redirect(url_for('home'))
    else:
        flash('Failed to update event.', 'error')
        return redirect(url_for('editevent', id=event_id))


@app.route('/login', methods=["POST"])
def login():
    email = request.form.get('lemail')
    password = request.form.get('lpassword')

    user = mongo.db.Users.find_one({"email": email, "password": password})
    if user:
        user_id = str(user['_id'])
        special_key = user.get("special key", "")
        global CurrentUser
        if special_key == "admin":
            CurrentUser = Admin(user["name"], email, special_key)
            unapproved_events = mongo.db.Event.find({"verified": "false"})
            CurrentUser.special_key = special_key
            CurrentUser.id = user_id
            return render_template('customerprofile.html', user=CurrentUser, unapproved_events=unapproved_events)
        elif special_key == "host":
            CurrentUser = Host(user["name"], email, special_key, [])
            CurrentUser.special_key = special_key
            CurrentUser.id = user_id
        else:
            CurrentUser = Attendee(user["name"], email)
            CurrentUser.id = user_id

        return redirect(url_for('home'))
    else:
        logSuccess = False
        logIssue = "No user found under: " + email

    # Probably will go back to the home page and give a little "successfully registered/logged in instead"
    # Failed login would not change the page
    if logSuccess:
        return redirect(url_for('home'))
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
        user = mongo.db.Users.find_one({"email": email, "password": password})
        user_id = str(user['_id'])
        CurrentUser.id = user_id
        # Redirect to profile page with success message
        return redirect(url_for('customerprofile', regSuccess=True))


@app.route('/checkout')
def checkout():
    if CurrentUser is None:
        return render_template('loginandregister.html')

    cart_items = session.get('cart', [])
    events_in_cart = []
    total = 0
    num_tickets = 0  # Initialize num_tickets

    for item in cart_items:
        event = mongo.db.Event.find_one({"_id": ObjectId(item['event_id'])})
        if event:
            event_detail = {
                "name": event['name'],
                "num_tickets": item['num_tickets'],
                "ticket_price": event.get('ticket_price', 0),
                "total_price": item['num_tickets'] * event.get('ticket_price',0)
            }
            events_in_cart.append(event_detail)
            total += event_detail["total_price"]
            num_tickets += item['num_tickets']

    return render_template('checkout.html', events_in_cart=events_in_cart, total=total, num_tickets=num_tickets)


@app.route('/purchase', methods=["POST"])
def purchase():
    # After processing, clear the session cart and show a success message
    cart = session.pop('cart', None)
    if cart is None:
        flash('No items in cart.', 'error')
        return redirect(url_for('checkout'))

    userId = mongo.db.Users.find_one({"email": CurrentUser.email})['_id']
    for item in cart:
        if item['num_tickets'] > 0:
            generateTickets(ObjectId(item['event_id']), userId, item['num_tickets'])
        else:
            flash('Invalid number of tickets.', 'error')

    flash('Purchase successful! Thank you.', 'success')
    return redirect(url_for('checkout'))


@app.route('/admin')
def admin():
    return render_template('admin.html')


@app.route('/search', methods=['GET', 'POST'])
def search():
    if request.method == 'POST':
        # Get the search term from search bar
        search_term = request.form['search_term'].strip()  # Trim whitespaces
        # Get the search date from date section
        date_str = request.form['search_date']

        # Build the query based on search term
        query = {
            "$or": [
                {"name": {"$regex": f".*{search_term}.*", "$options": "i"}},
                {"location": {"$regex": f".*{search_term}.*", "$options": "i"}},
                {"description": {"$regex": f".*{search_term}.*", "$options": "i"}},
                {"artist": {"$regex": f".*{search_term}.*", "$options": "i"}},
                {"genre": {"$regex": f".*{search_term}.*", "$options": "i"}},
            ]
        }

        # Mandate verified status
        query = {
            "$and": [
                query,
                {"verified": "verified"}
            ]
        }

        # If user selects a date
        if date_str:
            # Convert the date string (YYYY-MM-DD) to a datetime object
            from datetime import datetime, timedelta
            search_date = datetime.strptime(date_str, '%Y-%m-%d')

            query = {
                "$and": [
                    query,
                    {"verified": "verified"},
                    {"date": {'$gte': search_date, '$lt': search_date + timedelta(days=1)}}
                ]
            }

        # Fetch results from db
        results = mongo.db.Event.find(query)

        return render_template('index.html', events=results)

    return render_template('index.html')


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


@app.route('/cancel_event', methods=['POST'])
def cancel_event():
    if CurrentUser is not None and CurrentUser.special_key == "host":
        event_id = request.form.get('event_id')
        mongo.db.Event.update_one({'_id': ObjectId(event_id)}, {'$set': {'cancelled': True}})
        flash('Event cancelled successfully.', 'success')
        return redirect(url_for('hostEvents'))
    else:
        flash('You do not have permission to perform this action.', 'error')
        return redirect(url_for('customerprofile'))

@app.route('/decline_event', methods=['POST'])
def decline_event():
    if 'event_id' in request.form:
        event_id = request.form['event_id']
        mongo.db.Event.update_one({'_id': ObjectId(event_id)}, {'$set': {'verified': 'declined'}})
        flash('Event declined successfully.', 'success')
    else:
        flash('Event decline failed. No ID provided.', 'error')
    return redirect(url_for('eventapproval'))


@app.route('/add_to_cart')
def add_to_cart():
    if 'cart' not in session:
        session['cart'] = []

    event_id = request.args.get('event_id')
    num_tickets = int(request.args.get('num_tickets', 1))

    event = mongo.db.Event.find_one({"_id": ObjectId(event_id)})
    if not event:
        flash('Event not found', 'danger')
        return redirect(url_for('events'))

    cart = session.get('cart')
    event_in_cart = next((item for item in cart if item['event_id'] == event_id), None)
    if event_in_cart:
        event_in_cart['num_tickets'] = num_tickets
    else:
        cart.append({'event_id': event_id, 'num_tickets': num_tickets})
    session['cart'] = cart

    flash('Ticket added to cart!', 'success')
    return redirect(url_for('checkout'))


@app.route('/myevents')
def myevents():
    if CurrentUser is not None and CurrentUser.special_key == 'host':
        waiting_approval_events = mongo.db.Event.find({"verified": "false", "host": CurrentUser.email})
        approved_events = mongo.db.Event.find({"verified": "verified", "host": CurrentUser.email})
        declined_events = mongo.db.Event.find({"verified": "declined", "host": CurrentUser.email})

        return render_template('myevents.html',
                               waiting_approval_events=waiting_approval_events,
                               approved_events=approved_events,
                               declined_events=declined_events)
    else:
        flash('You do not have permission to view this page.', 'error')
        return redirect(url_for('home'))


@app.route('/mytickets')
def mytickets():
    if not CurrentUser:
        flash("Please log in to view your tickets.", "info")
        return redirect(url_for('loginRegister'))

    user_id = ObjectId(CurrentUser.id)
    user_tickets = mongo.db.Ticket.find({'user_id': user_id})
    ticket_event_info = []
    for ticket in user_tickets:
        event = mongo.db.Event.find_one({"_id": ObjectId(ticket["event_id"])})
        if event:
            ticket_event_info.append({
                "ticket_id": str(ticket["_id"]),
                "event_name": event["name"],
                "event_description": event["description"],
                "event_date": event["event_date"],
                "event_location": event["location"],
                "ticket_price": event["ticket_price"]
            })

    return render_template('mytickets.html', ticket_event_info=ticket_event_info)


if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5001)