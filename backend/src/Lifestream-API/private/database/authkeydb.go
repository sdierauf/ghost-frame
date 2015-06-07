package database

type AuthKeyDB interface {
	/**
	 * Connect function to connect to the relevant key database
	 */
	Connect() bool
}
