import time
import redis
from flask import *
from flask_pymongo import PyMongo
from bson.objectid import *
from user import *
#from ticket import *

app = Flask(__name__)
app.secret_key = "testSecretKeySoIDon'tHaveToLooseMyMindTryingToRetainDataTypingViaHiddenFormFields"
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
    if logSuccess:
        return redirect(url_for('events'))
    else:
        return render_template('loginandregister.html', loginIssue=logIssue)


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
    if CurrentUser == None:
        return render_template('loginandregister.html')
    numTickets = request.args.get('numTickets')
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
        print("u suck")
        # Go back to events? idk    
    # Process valid card details but like we're really just checking the card number
    #TODO 
    #if ccNum is valid # The credit card checking algorithm probably needs its own function, and I don't want to go find out what it is right now and it also doesn't matter as much as the rest of this loop
    if True: # the if ccNum is valid check would replace this if statement
        if CurrentUser is None:
            return redirect(url_for('events'))
        targetUserId = mongo.db.Users.find_one({"email":CurrentUser.email})['_id']
        for t in tickets:# This line needs testing but it should in theory work
            mongo.db.Ticket.find_one_and_replace({'_id':ObjectId(t['_id'])}, 
                                                {"_id":ObjectId(t['_id']), "price":t['price'],
                                                 "seat_number":t['seat_number'], "event_id":ObjectId(t['event_id']), 
                                                 "user_id":targetUserId})
        return('purchase_success.html') #maybe we just go back to the main page with a purchase complete message instead
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


@app.route('/customerProfile')
def customerprofile():
    if CurrentUser is not None:
        # Assuming CurrentUser.email is the email of the logged-in user
        user_info = mongo.db.Users.find_one({"email": CurrentUser.email})
        if user_info:
            # Pass the user_info to the template
            return render_template('customerProfile.html', user=user_info)
        else:
            # User info not found, handle accordingly (e.g., redirect or show an error message)
            return render_template('customerProfile.html', error="User information not found.")
    else:
        # No user is logged in, redirect to login page
        return redirect(url_for('loginRegister'))


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

if __name__ == '__main__':
    app.run(debug=True)