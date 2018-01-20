function playback(file) {
    var req = "http://192.168.10.200/functions/playback.php?file=" + file;
    var xhr = new XMLHttpRequest;
    xhr.open("GET", req, true);
    xhr.send()
}

function updateHome() {
    produseModel.clear();
    for (var i = 0; i < produseModel.count; i++ ) {
        if (produseModel.get(i).vanzari !== 0)
            emptyModel.append({
                                  id: produseModel.get(i).id,
                                  cod: produseModel.get(i).cod,
                                  nume: produseModel.get(i).nume,
                                  pret: produseModel.get(i).pret,
                                  tva: produseModel.get(i).tva,
                                  imagine: produseModel.get(i).imagine,
                                  cant: produseModel.get(i).cant,
                                  index_prod: i,
                                  by_search: false
                              })
    }
}

function lcd(mod) {
    var nr_prod = cosModel.count
    if (nr_prod === 0)
        mod = 2

    var arguments = ""
    var nume
    if (mod === 1) {
        if(cosModel.get(listview1.currentIndex).cod !== cod_curent) {
            nume = cosModel.get(listview1.currentIndex).nume
            cod_curent = cosModel.get(listview1.currentIndex).cod
            cod_curent = cosModel.get(listview1.currentIndex).cod
        }
        else {
            nume = ""
        }
        arguments = "&nume=" + nume;
        arguments += "&cant=" + cosModel.get(listview1.currentIndex).cantitate;
        arguments += "&pret=" + cosModel.get(listview1.currentIndex).pret;
        arguments += "&tva=" + cosModel.get(listview1.currentIndex).tva;
        arguments += "&total=" + total
        arguments += "&nr_prod=" + nr_prod;
        var i = 0
        var counter = 1
        while (nr_prod > i && counter < 5) {
            if (listview1.currentIndex !== i) {
                arguments += "&prod" + counter + "=" + cosModel.get(i).nume + ";" + (cosModel.get(i).pret * cosModel.get(i).cantitate).toFixed(2)
            }
            else
                counter--
            i++
            counter++
        }
    }
    var req = "http://192.168.10.200/functions/lcd.php?mod=" + mod + arguments;
    //console.log(req)
    var xhr = new XMLHttpRequest;
    xhr.open("GET", req, true);
    xhr.send()
}
