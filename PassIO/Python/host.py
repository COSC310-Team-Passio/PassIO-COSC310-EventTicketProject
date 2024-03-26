from user import User
import event, venue
from flask import Flask, render_template
from flask_pymongo import PyMongo

class Host(User):

    def __init__(self, name, email, password, host_key, hosting_history):
        super().__init__(name, email, password)
        self.__host_key = host_key
        self.hosting_history = []
    

    def add_hosting_history(self, e):
        self.hosting_history.append(e)

    def __create_event(self, name, genre, artist, date):
        self.add_hosting_history(self, event.Event(name, genre, artist, date))

    def __add_venue(self, name, location, capacity):
        venue.Venue(name, location, capacity)

    