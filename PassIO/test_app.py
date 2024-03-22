import mongomock
import pytest
from app import app as flask_app


@pytest.fixture
def app():
    flask_app.config['TESTING'] = True
    flask_app.config['MONGO_URI'] = "mongomock://localhost"
    yield flask_app


@pytest.fixture
def client(app):
    return app.test_client()


@pytest.fixture
def runner(app):
    return app.test_cli_runner()


@mongomock.patch(servers=(('localhost', 27017),))
def test_update_profile(client):
    # Test data
    test_data = {'firstName': 'John', 'email': 'john@example.com', 'password': '123456'}

    # Send POST request to update_profile route
    response = client.post('/update_profile', data=test_data, follow_redirects=True)

    # Assert that redirect happened to '/index' (which means update was successful)
    assert response.request.path == '/index'

    # Optionally, check if the data was "inserted" into the mock database
    # This requires accessing the app context to get the PyMongo instance
    with flask_app.app_context():
        mongo = flask_app.extensions['pymongo']
        user = mongo.db.Users.find_one({'email': 'john@example.com'})
        assert user is not None
        assert user['name'] == 'John'
        assert user['password'] == '123456'
