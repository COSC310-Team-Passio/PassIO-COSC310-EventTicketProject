CREATE DATABASE Passio;
GO

USE Passio;
GO

CREATE TABLE Customer (
    CustomerId INT IDENTITY PRIMARY KEY,
    FirstName VARCHAR(40),
    LastName VARCHAR(40),
    Email VARCHAR(50),
    PhoneNum VARCHAR(20),
    UserId VARCHAR(20),
    Password VARCHAR(30)
);

CREATE TABLE PaymentMethod (
    PaymentMethodId INT IDENTITY PRIMARY KEY,
    PaymentType VARCHAR(20),
    PaymentNumber VARCHAR(30),
    PaymentExpiryDate DATE,
    CustomerId INT,
    FOREIGN KEY (CustomerId) REFERENCES Customer(CustomerId)
);

CREATE TABLE Event (
    EventId INT IDENTITY PRIMARY KEY,
    EventName VARCHAR(100),
    EventDate DATETIME,
    EventLocation VARCHAR(100),
    EventDescription VARCHAR(1000),
    BaseTicketPrice DECIMAL(10,2)
);

CREATE TABLE Ticket (
    TicketId INT IDENTITY PRIMARY KEY,
    EventId INT,
    CustomerId INT,
    PurchaseDate DATETIME,
    TicketType VARCHAR(50),
    Price DECIMAL(10,2),
    FOREIGN KEY (EventId) REFERENCES Event(EventId),
    FOREIGN KEY (CustomerId) REFERENCES Customer(CustomerId)
);