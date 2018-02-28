# Shiny Items Selection Form (Example Application)

This is a simple Shiny web application to collect item selection responses (like a web form).  Thanks to Dean Attali for his [great tutorial on preparing web forms with R and Shiny](https://deanattali.com/2015/06/14/mimicking-google-form-shiny/), which I used to help create this application.

The use case for this application is to provide a web form that users/participants can used to select or vote for "items" of interest.  A fixed set of items are listed as check-box inputs, and a text box is provided for free-form entry.  Currently, the application requires that a user must select a specified number of items, but this can be easily modified as needed.

Once the requirements of the form are met (in this case, the user enters their name and selects the specified number of items), the user can submit their responses via the *Submit Responses* button.  This button is not active until these conditions are met to prevent incomplete responses from being submitted.

Response data is saved to local server storage in the project's ```response_data``` folder as a .csv file, with one file per submission.  A simple ```tally_responses.R``` script is provided in this directory to count up the selected items across all responses.  NOTE: the Shiny user on the server that runs the application must have write privileges to the ```response_data``` folder.  NOTE 2: this mode of saving user data is not suitable for servers that you don't have access to and/or servers that don't consistently serve the application on the same computer (e.g. shinyapps.io).
