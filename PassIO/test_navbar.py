import unittest
from flask import *
from app import *

# import unittest and app above

app = Flask(__name__)


# create NavbarTestCase and inherit TestCase from unittest

class NavbarTestCase(unittest.TestCase):
    # create setup method to prepare for testing
    def setUp(self):
        # Following line used to make requests without running server
        self.app = app.test_client()
        # Allow testing and not break anything else
        self.app.testing = True

    # define method to test if home page loads
    def test_home_page_loads(self):
        # get response from / and store it in response
        response = self.app.get('/')
        # see if the response was correct, if its correct it'll be 200 and these two will be equal
        self.assertEqual(response.status_code, 200)
        # checking if PassIO is in the response, if it is then it worked
        self.assertIn(b'PassIO', response.data)

        # define method to test events page same as above

    def test_events_page_loads(self):
        response = self.app.get('/events')
        self.assertEqual(response.status_code, 200)
        self.assertIn(b'Events', response.data)

    # define method to test checkout page same as above
    def test_checkout_page_loads(self):
        response = self.app.get('/checkout')
        self.assertEqual(response.status_code, 200)
        self.assertIn(b'Checkout', response.data)

    # define method to test hostentry page same as above
    def test_host_entry_page_loads(self):
        response = self.app.get('/hostEntry')
        self.assertEqual(response.status_code, 200)
        self.assertIn(b'Host Entry', response.data)

    # # define method to test events page same as above
    def test_event_entry_page_loads(self):
        response = self.app.get('/events_entry')
        self.assertEqual(response.status_code, 200)
        self.assertIn(b'Event Entry', response.data)


# run all test methods in class
if __name__ == '__main__':
    unittest.main()
