# BotBot 🤖

<img src="/Public/images/github-header.png?raw=true" width="888">

Post & create [Marvel](https://marvelapp.com) projects directly from Slack, written in Swift (Vapor).

Build your own integration using the [Marvel API](https://marvelapp.com/developers/).

[Try it out](https://botbot.marvelapp.com)

## 🎒 Before building (dependencies)
* Install [Xcode](https://developer.apple.com/xcode/)
* Install [Vapor Toolbox](https://github.com/vapor/toolbox)
* Run ```vapor xcode -y```, this will create & open the Xcode project
* Run ```brew install mysql``` followed by ```mysql_secure_installation``` to set up a database
* Create a MySQL database called ```marvel```, e.g. using the mysql CLI: ```CREATE DATABASE marvel;```
* Change the [Config/mysql.json](Config/mysql.json) credentials

## 🚧 Building
* Run the ```App``` target in Xcode
* The bot should now be running on [http://localhost:8080](http://localhost:8080)

## 💟 Heroku:
* Add a ClearDB MySQL Database in Heroku
* Add the Config Variables that are found in the Procfile
* Deploy using ```git push heroku master```

## 📖 Documentation
Visit the Vapor web framework's [documentation](http://docs.vapor.codes) for instructions on how to use this package.

## 💧 Community
Join the welcoming community of fellow Vapor developers in [Slack](http://vapor.team).

## 🔧 Compatibility
This package has been tested on macOS and Heroku.
