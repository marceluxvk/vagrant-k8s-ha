package main

import (
	"encoding/json"
	"log"
	"net/http"
	"strconv"
)

var (
	drinks = make([]Item, 0)
)

type Item struct {
	ID    int     `json:"id"`
	Name  string  `json:"name"`
	Price float32 `json:"price"`
}

func init() {
	addDrink(1, "Caipirinha", 10.0)
	addDrink(2, "CaipiSake", 8.1)
	addDrink(3, "Budweiser", .3)
	addDrink(4, "Heineken", 3.2)
}

func addDrink(id int, name string, price float32) {
	item := Item{
		ID:    id,
		Name:  name,
		Price: price,
	}

	drinks = append(drinks, item)
}

func GetMenu(w http.ResponseWriter, r *http.Request) {
	bytes, err := json.Marshal(drinks)
	if err != nil {
		log.Panicf("ERROR! %v", err)
	}
	w.WriteHeader(http.StatusOK)
	w.Write(bytes)

}

func Prepare(w http.ResponseWriter, r *http.Request) {
	id := r.URL.Query().Get("id")
	for _, drink := range drinks {
		if strconv.Itoa(drink.ID) == id {
			bytes, _ := json.Marshal(drink)
			w.Write(bytes)
			w.WriteHeader(http.StatusOK)

			return
		}
	}
	w.WriteHeader(http.StatusNotFound)
}

func main() {
	http.HandleFunc("/menu", GetMenu)
	http.HandleFunc("/order", Prepare)

	log.Panic(http.ListenAndServe(":7000", nil))
}
