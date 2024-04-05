import unittest
from unittest.mock import patch
from flask import Flask, render_template
from app import app  # Importing the Flask app
'''
This test indicates that when we request for data to be displayed, the method /events_display is returning an html with the content we expect via the flask
application. It also indicates that this is running correctly (200), and is all done utilizing a mock DB. 
This code has a lot of comments as I am using it as a learning tool for myself. -BD
'''
class TestEventsDisplay(unittest.TestCase):
    def setUp(self):
        self.app = app.test_client()


    @patch('app.mongo')  # Mocking the mongo object
    def test_events_display(self, mock_mongo):
        # Mock the return value of mongo.db.Event.find()
        mock_db = mock_mongo.db
        #This presets our "return" from the get request to be as follows
        mock_db.Event.find.return_value = [{'name': 'Event 1'}, {'name': 'Event 2'}]

        with self.app as client: #this allows us to access this via flask route
            # Make a GET request to the /events_display route
            response = client.get('/events_display')

            # Assert that the status code is 200 --> ran correctly
            self.assertEqual(response.status_code, 200)

            # Assert that the rendered template is 'events.html', or at least is html
            #text/html = content type is html being returned
            #charset... just indicates that it is the caracter type that we expect from our html (this is set as meta at the top of our html)
            self.assertEqual(response.content_type, 'text/html; charset=utf-8')

            # Extract the rendered HTML content
            #response is simply just the response that flask is returning
            #get data is returning simply the data of the response object (binary or bytes)
            #as_text means that the returned data should be in text form
            html_content = response.get_data(as_text=True)

            # Assert that the events are present in (ie. assertIn) the rendered HTML that we preset in our expected request above.
            self.assertIn('Event 1', html_content)
            self.assertIn('Event 2', html_content)

if __name__ == '__main__':
    unittest.main()
