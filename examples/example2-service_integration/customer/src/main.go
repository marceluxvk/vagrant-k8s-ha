package main

import (
	"encoding/json"
	"io/ioutil"
	"log"
	"math/rand"
	"net/http"
	"os"
	"strconv"
)

var (
	service string
)

type Item struct {
	ID    int     `json:"id"`
	Name  string  `json:"name"`
	Price float32 `json:"price"`
}

func init() {
	service = os.Getenv("EXAMPLE2_BARTENDER_SERVICE_SERVICE_HOST") + ":" + os.Getenv("EXAMPLE2_BARTENDER_SERVICE_SERVICE_PORT")

	if service == ":" {
		service = "localhost:7000"
	}
}

func AskForBeer(w http.ResponseWriter, r *http.Request) {
	resp, err := http.Get("http://" + service + "/menu")
	log.Println("Menu received")
	if err != nil {
		w.Write([]byte(err.Error()))
		w.WriteHeader(http.StatusServiceUnavailable)
	} else if resp.StatusCode != 200 {
		w.Write([]byte("The external service failed"))
		w.WriteHeader(http.StatusServiceUnavailable)
	} else {
		buf, _ := ioutil.ReadAll(resp.Body)
		var drinks []Item

		err := json.Unmarshal(buf, &drinks)

		if err != nil {
			log.Print(drinks)
		} else {
			log.Printf("Choosing drink")
			drink := drinks[rand.Intn(len(drinks))]

			log.Println("Ordering")
			resp, _ = http.Get("http://" + service + "/order?id=" + strconv.Itoa(drink.ID))
			buf, _ = ioutil.ReadAll(resp.Body)

			w.Write(buf)
			w.WriteHeader(resp.StatusCode)
			log.Println("Tks man!")
		}
	}
}

func main() {
	http.HandleFunc("/", AskForBeer)
	log.Panic(http.ListenAndServe(":7100", nil))
}
