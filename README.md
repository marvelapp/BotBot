# BotBot 🤖

<img src="/Public/images/github-header.png?raw=true" width="888">

BotBot is an open-source Slackbot for [Marvel](https://marvelapp.com) - a design collaboration platform that brings ideas to life.

[Go to BotBot and install](https://botbot.marvelapp.com)

BotBot allows you and your team to create, view and manage Marvel projects directly inside of Slack.

**Why it's so amazing**
* Anyone in your team can quickly pull up a list of Marvel projects without leaving Slack by typing ```/projects```
* Create a project in seconds by typing ```/create-project```
* Add people to projects by typing ```/add-people```
* Or just grab the code and roll your own bot

Built using the Marvel GraphQL API - [get started here]([Marvel GraphQL API](https://marvelapp.com/developers/).

Questions? Hit us up on [Twitter](http://twitter.com/marvelapp)

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
