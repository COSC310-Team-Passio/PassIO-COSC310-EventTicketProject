class User(object):
    id_counter = 0

    def __init__(self, name, email, password):
        self.name = name
        self.email = email
        self.password = password
        self.__id = User.id_counter
        User.id_counter += 1

    def get_id(self):
        return self.__id

    def log_in(self, email, password):
        return self.email == email and self.password == password

    def __del__(self):
        # Need to import the pymongo stuff but want to make a general db connection function that all classes can use
        # mongo.db.findOneAndRemove({account info here})
        print("Your account has been deleted.")
        return True # Status of if account is successfully deleted or not

# import venue, event

class Admin(User):
    def __init__(self, name, email, password, admin_key):
        super().__init__(name, email, password)
        self.__admin_key = admin_key

    def __verify_venue(venue):
        # TODO: complete function
        return True

    def __verify_event(event):
        # TODO: complete function
        return True

class Host(User):
    def __init__(self, name, email, password, host_key, hosting_history):
        super().__init__(name, email, password)
        self.__host_key = host_key
        self.hosting_history = []

    def add_hosting_history(self, e):
        self.hosting_history.append(e)

    def __create_event(self, name, genre, artist, date):
        print("")
        # event.Event(name, genre, artist, date)

    def __add_venue(self, name, location, capacity):
        print("")
        # venue.Venue(name, location, capacity)
        
# import user, ticket, review
class Attendee(User):

    def __init__(self, name, email, password):
        super().__init__(name, email, password)
        self.preferred_genres = []
        self.purchase_history = []

    def add_genre(self, genre):
        self.preferred_genres.append(genre)

    def add_purchase_history(self, t):
        self.purchase_history.append(t)

    def __buy_ticket(t):
        # TODO: complete function
        return True

    def __connect_wallet(obj):
        # TODO: complete function
        return True

    def __cancel_ticket(ticket):
        # TODO: complete function
        return True

    def write_review(self, rating, description):
        print("") # blank code so that the function stops screaming at me
        #review.Review(rating, description)
