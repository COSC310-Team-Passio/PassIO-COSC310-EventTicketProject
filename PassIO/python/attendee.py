import user, ticket, review
class Attendee(user.User):

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
        review.Review(rating, description)
