LiveSnooker-Server
==================

Dependencies
------------
* PostgreSQL >= 9.4
* Redis >= 3.0
* Node >=4.2.2

Installation
------------
```
npm install
```

Run development server
------------
Copy environments/sample.env to environments/development.env and modify values (defaults might also work for you). Then run:
```
./grunt.sh serve
```

Testing
-------
Run:
```
./grunt.sh test
```

Or to run tests when files change:
```
./grunt.sh tdd
```
