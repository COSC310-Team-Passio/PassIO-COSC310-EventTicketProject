import event, venue
class Host:

    def __init__(self, name, email, password, host_key, hosting_history):
        super().__init__(name, email, password)
        self.__host_key = host_key
        self.hosting_history = []

    def add_hosting_history(self, e):
        self.hosting_history.append(e)

    def __create_event(self, name, genre, artist, date):
        event.Event(name, genre, artist, date)

    def __add_venue(self, name, location, capacity):
        venue.Venue(name, location, capacity)