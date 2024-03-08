class Ticket:

    id_counter = 0

    def __init__(self, price):
        self.price = price
        self.__id = Ticket.id_counter
        Ticket.id_counter += 1

    def get_id(self):
        return self.__id

    def use_ticket(self):
        # TODO: complete function
        pass