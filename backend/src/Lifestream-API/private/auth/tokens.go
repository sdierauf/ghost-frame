package auth

import (
	uuid "code.google.com/p/go-uuid/uuid"
)

type ApiToken struct {
	owner string
	requests int
	token string
	level string
}

/**
 * Function to add a new token
 * It is automatically inserted into the database
 */
func (ap ApiToken) NewToken(owner string, level string) (status bool, token string) {
	ap.owner = owner
	ap.level = level
	ap.token = uuid.New()
	ap.requests = 0
	// insert it into database here
	// check for errors
	// if err {
	// 		return (false, message)
	// } else {
	// 		return (true, token)
	// }
	token = ap.token
	status = true
	return
}

/**
 * Function to check if the token is valid
 * This function also checks usage limits of the token (if any)
 */
func (ap ApiToken) CheckToken(token string) bool {
	// check if it exists in database here
	// check usage limits here
	// if exists {
	// 		return true
	// } else {
	// 		return false
	// }
	return true
}

/**
 * Function to delete a token from the databse
 * Returns true if successful, false if not
 */
func (ap ApiToken) DeleteToken(token string) bool {
	// find token in db, delete it
	// if successful {
	// 		return true
	// } else {
	// 		return false
	// }
	return true
}