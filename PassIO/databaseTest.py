from pymongo.mongo_client import MongoClient
from pymongo.server_api import ServerApi

def connect():
    username = "kaycee.goel.42%40gmail.com"
    password = "haramemes_69"
    uri = "mongodb+srv://"+username+":"+password+"@passioatlas.foiwof6.mongodb.net/?retryWrites=true&w=majority"
    # Create a new client and connect to the server
    client = MongoClient(uri, server_api=ServerApi('1'))
    # Send a ping to confirm a successful connection
    try:
        client.admin.command('ping')
        print("Pinged your deployment. You successfully connected to MongoDB!")
    except Exception as e:
        print(e)
        
connect()