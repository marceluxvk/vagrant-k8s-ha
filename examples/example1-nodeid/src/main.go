package main

import (
	"log"
	"net/http"
	"os"
)

func handler(w http.ResponseWriter, r *http.Request) {
	hostname, _ := os.Hostname()
	w.Write([]byte("The hostname is: " + hostname + "\n"))
}

func main() {
	http.HandleFunc("/", handler)
	log.Panic(http.ListenAndServe(":7000", nil))
}
