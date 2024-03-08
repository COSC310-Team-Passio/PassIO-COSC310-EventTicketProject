class Event:

    id_counter = 0

    def __init__(self, name, genre, artist, date, venue):
        self.name = name
        self.genre = genre
        self.artist = artist
        self.date = date
        self.__verified = False
        self.venue = venue
        self.__id = Event.id_counter
        Event.id_counter += 1

    def get_id(self):
        return self.__id

    def _conclude_event(self):
        # TODO: complete function
        return True

    def __make_announcement(self):
        # TODO: complete function
        pass