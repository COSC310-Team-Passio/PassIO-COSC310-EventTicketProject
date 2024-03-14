class User:

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
        # mongo.db.findOneAndRemove({})
        print("Your account has been deleted.")
        return True # Status of if account is successfully deleted
