# Gorilla

Gorilla is a rails/javascript re-implementation of the biological tool
[ApE][ape]. 

# To Run Gorilla
Once you have checked out the project, you'll need to run the following
commands

```
$ rake db:create
$ rake db:migrate
```

to get the databases up and running.

Then you will need to run: 

```
$ rails server
```

Once the server is running you can navigate to: 

```
http://localhost:3000/
```

Once you log in to the website, you will be taken to a page where you can
either enter the contents of a GenBank/ApE file in a text box, or you can
specify the URL of a GenBank/ApE file that can be loaded. 

The following file can be used in the URL field for quick testing:

```
public/test1.ape
```

# Testing
To run the testing suite simply run

```
$ rake test
```

[ape]: http://biologylabs.utah.edu/jorgensen/wayned/ape/ "A Plasmid Editor"
