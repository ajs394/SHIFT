README – SHIFT Health Care Imaging
Objective:
The goal of the SHIFT: Health Care Imaging Project, was to create an application that can be used on an iOS mobile device to gather medical information from a medical record image and use that information to search the web in a useful way.

Program Description:
The following is an example use case of the application:
A user scans a QR code from a computer screen to obtain information about a patient’s name, age, medical reference number, and a list of symptoms.  The application then prompts the user to identify which of these fields he would like to use and the user selects the list of symptoms.  Next, the application offers a list of options to the user about how to use this information.  The user selects a website such as PubMed, and the symptoms gathered would be used as keywords to search the website.  The information retrieved from the site is then displayed on the mobile device’s screen for the user to read.

Contents:
Help Page.doc
Engine folder:
File Name	Function
index.erb	the home page
new_setup.erb	choose the number of attributes that will be included in the newly made engine
new.erb	create a new engine
showR_setup.erb	choose the engine with which to search for the information provided in the QR code
showR.erb	show the result of the QR code
edit.erb	update the chosen engine information and give the ability to delete the engine
engindex.erb	shows all the engines contained in the system with a link to show more information and update them
engine.rb	synchronize the engine database
engine_controller.rb	the controller that mange all the calls to the server
enter_setup.erb	choose the engine with which to search on manually entered values
enter.erb	enter the values of the search manually
help.erb	contains useful instructions on how to use this app

Suggested areas of expansion:
•	Apply OCR to recognize text from a paper or from a computer screen.
•	Active QR code recognition.
•	Serial search:   
Tips on using Rhostudio:
•	Install the Java SDK and Android SDK into directories without spaces (NOT C:\Program Files\, which is the default)

