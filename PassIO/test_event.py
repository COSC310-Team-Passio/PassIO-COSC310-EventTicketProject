import unittest
from unittest.mock import patch #also allows me to use mock_mongo
from app import app  # Importing the Flask app

#I have added a lot of comments to aid with my understanding of the code.

class TestEventsSubmit(unittest.TestCase):
    def setUp(self):
        self.app = app.test_client() #simulates Flask requests without running the server.
        #Now can simulate http requests via flask

    @patch('app.mongo') #Makes a mock object to replace the DB
    def test_events_submit(self, mock_mongo):
        with self.app as client: #the test_client we made above is used as our client (aka the object being used for the requests)
            # Mock data form, this is what we would be sending in a post request.
            #simulates the data typically submitteed via the html form.
            data = {'e_name': 'Test Event',
                    'e_location': 'Test Location',
                    'e_description': 'Test Description',
                    'e_artist': 'Test Artist',
                    'e_genre': 'Test Genre',
                    'e_verified': 'True'}

            # Mock MongoDB creation
            mock_db = mock_mongo.db #This is creating the mock database
            mock_db.Event.insert_one.return_value = None #Mock insert, set to None as we are not concerned with the return value of the mock.

            # Make a POST request to the /events_submit route using the above item labelled "data" as the information passed.
            response = client.post('/events_submit', data=data)

            # Assertions
            #First one: shows that we are able to submit to the form and it successfully able to submit the request.
            self.assertEqual(response.status_code, 200)  # this is referring to the HTTP status code (404 is one we see all the time). code of 200 just means that the request was successful)
           #mock_db.Event.insert_one is using the mock db object to run the Event.insert_one function
           #".assert_called_once_with" is from the unittest.mock library
            #overall this makes sure that this is only run once and runs with these specific arguments.
            mock_db.Event.insert_one.assert_called_once_with({'name': 'Test Event',
                                                              'location': 'Test Location',
                                                              'description': 'Test Description',
                                                              'artist': 'Test Artist',
                                                              'genre': 'Test Genre',
                                                              'verified': 'True'})


if __name__ == '__main__':
    unittest.main()


