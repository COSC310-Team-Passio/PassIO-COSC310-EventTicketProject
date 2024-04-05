from pymongo import MongoClient
import os

# Using Environment Variables for Security
client = MongoClient(os.environ.get('mongodb+srv://passio:passio@passioatlas.foiwof6.mongodb.net/passio_db?retryWrites=true&w'))
db = client['passio_db']  
