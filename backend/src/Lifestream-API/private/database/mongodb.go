package database

import(
	"fmt"
	"gopkg.in/mgo.v2"
	//"gopkg.in/mgo.v2/bson"
)

type MongoDB struct {
	host string
	port string
	username string
	password string
	appName string
}

func (m MongoDB) Connect() bool {
	session, err := mgo.Dial(m.createMongoUrl(m.host, m.port, m.username, m.password, m.appName))
	if err != nil {
		fmt.Println(err)
		return false
	}
	session.Close()
	return true
}

/**
 * Function to construct the mongoDB URL for mgo when given the
 * host, port, username, password and appname of the database
 */
func (m MongoDB) createMongoUrl(host string, port string, username string, password string, appName string) string {
	var dbUrl string = ""
	// Checking if a username is given
	if username != "" {
		dbUrl = username
		// Checking if a password is given
		if password != "" {
			dbUrl += ":" + password
		}
		dbUrl += "@"
	}
	dbUrl += host
	if appName != "" {
		dbUrl += "/" + appName
	}
	return dbUrl
}