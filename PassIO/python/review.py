class Review:

    def __init__(self, rating, description):
        self.rating = rating
        self.description = description

    def _edit_review(self, rating, description):
        self.rating = rating
        self.description = description