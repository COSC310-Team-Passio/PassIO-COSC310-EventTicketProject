import unittest
import pytest  # You'll need pytest installed
from flask import json
from PassIO.app import app  # Import your main Flask app
from db_connection import db  # Import your database connection module.

# ------------------  Fixtures  ----------------------
@pytest.fixture()
def test_client():
    app.config['TESTING'] = True 
    with app.test_client() as client:
        yield client

@pytest.fixture(autouse=True)
def setup_database():
    db.your_collection_name.insert_many({}) # {'name': '', 'location': '', 'description': '', 'artist':'', 'genre':'', 'date':''}
    db.your_collection_name.delete_many({})


# ----------------  Test Cases  -------------------------
def test_search_by_name(test_client):
    search_term = 'Afro Fusion Party'
    expected_id = '6605c5ea89458c5ac6b68c7c' 
    response = test_client.post('/search', data={'search': search_term})
    assert response.status_code == 200
    data = response.json()  
    assert data[0]['_id'] == expected_id  
    
def test_search_by_location(test_client):
    search_term = 'Prospera Place'
    expected_id_1 = '6601fed54d1d66644fc6461c'
    expected_id_2 = '6605c71d89458c5ac6b68c7e'
    response = test_client.post('/search', data={'search': search_term})
    assert response.status_code == 200
    data = response.json()  
    assert data[0]['_id'] == expected_id_1  
    assert data[1]['_id'] == expected_id_2  
    
def test_search_by_artist(test_client):
    search_term = 'Taylor Swift'
    expected_id = '6601fed54d1d66644fc6461c'  
    response = test_client.post('/search', data={'search': search_term})
    assert response.status_code == 200
    data = response.json()  
    assert data[0]['_id'] == expected_id  
       
def test_search_by_genre(test_client):
    search_term = 'Jazz'
    expected_id = '6605c68889458c5ac6b68c7d'  
    response = test_client.post('/search', data={'search': search_term})
    assert response.status_code == 200
    data = response.json()  
    assert data[0]['_id'] == expected_id  
    
def test_search_whitespace(test_client):
    search_term = '  Taylor Swift '
    expected_id = '6601fed54d1d66644fc6461c'  
    response = test_client.post('/search', data={'search': search_term})
    assert response.status_code == 200
    data = response.json()  
    assert data[0]['_id'] == expected_id  
    
def test_search_substring(test_client):
    search_term = 'Prospera'
    expected_id_1 = '6601fed54d1d66644fc6461c'
    expected_id_2 = '6605c71d89458c5ac6b68c7e'
    response = test_client.post('/search', data={'search': search_term})
    assert response.status_code == 200
    data = response.json()  
    assert data[0]['_id'] == expected_id_1  
    assert data[1]['_id'] == expected_id_2  
    
def test_search_case_sensitivty(test_client):
    search_term = 'jAzZ'
    expected_id = '6605c68889458c5ac6b68c7d'  
    response = test_client.post('/search', data={'search': search_term})
    assert response.status_code == 200
    data = response.json()  
    assert data[0]['_id'] == expected_id  
    

def test_search_no_results(test_client):
    search_term = 'something not found' 
    response = test_client.post('/search', data={'search': search_term})
    assert response.status_code == 200
    data = response.json()
    assert len(data) == 0   

