Directions for running the application:

From the command line:
rails s

To begin editing a file with Gorilla, navigate to localhost:3000/testclient/client

You can insert an ApE file in the file text box and click process. This should open the file in the editor. 

If you would like to just use the test file that is on our server you can input "public/test1.ape" into the fileURL
box and press process.

The URL entered into the saveURL is where the save request will be sent with the current version of the ApE file.

To run tests, run rake rspec
