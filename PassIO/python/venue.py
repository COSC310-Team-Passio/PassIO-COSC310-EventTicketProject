class Venue:

    id_counter = 0

    def __init__(self, name, location, capacity):
        self.name = name
        self.location = location
        self.rating = 0
        self.__verified = False
        self._capacity = capacity
        self.__id = Venue.id_counter
        Venue.id_counter += 1

    def get_id(self):
        return self.__id

    def update_rating(self):
        # TODO: complete function
        pass

    def update_verification_status(self, verified):
        self.__verified = verified
