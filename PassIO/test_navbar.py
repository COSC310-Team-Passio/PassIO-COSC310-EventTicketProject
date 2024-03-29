import unittest
from flask import *
from app import *

app = Flask(__name__)
class NavbarTestCase(unittest.TestCase):
    def setUp(self):
        self.app = app.test_client()
        self.app.testing = True

    def test_home_page_loads(self):
        response = self.app.get('/')
        self.assertEqual(response.status_code, 200)
        self.assertIn(b'PassIO', response.data)  # Checks if 'PassIO' is in the response

    def test_events_page_loads(self):
        response = self.app.get('/events')
        self.assertEqual(response.status_code, 200)
        self.assertIn(b'Events', response.data)  # Adjust the expected content as necessary

    def test_checkout_page_loads(self):
        response = self.app.get('/checkout')
        self.assertEqual(response.status_code, 200)
        self.assertIn(b'Checkout', response.data)  # Adjust the expected content as necessary

    def test_host_entry_page_loads(self):
        response = self.app.get('/hostEntry')
        self.assertEqual(response.status_code, 200)
        self.assertIn(b'Host Entry', response.data)  # Adjust the expected content as necessary

    def test_event_entry_page_loads(self):
        response = self.app.get('/events_entry')
        self.assertEqual(response.status_code, 200)
        self.assertIn(b'Event Entry', response.data)  # Adjust the expected content as necessary

if __name__ == '__main__':
    unittest.main()
