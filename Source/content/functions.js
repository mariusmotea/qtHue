var category = {};
var saved_product_list = {};

function pyconn(data, callback) {
    var xhr = new XMLHttpRequest
    xhr.open("POST", 'http://127.0.0.1:8080', true);
    xhr.setRequestHeader("Content-type", "application/json");
    xhr.onreadystatechange = function() {
        if (xhr.readyState === 4 && xhr.status === 200) {
            var response = JSON.parse(xhr.responseText)
            callback(response);
            console.warn(xhr.responseText);
            return response.length
        }
    }
    xhr.send(JSON.stringify(data));
}

function updateCategories(data) {
    if (data.length !== 0) {
        categoriesModel.clear();
        categoriesListView.currentIndex = -1
        for (var i = 0; i < data.length; i++) {
            categoriesModel.append({
                                       id: data[i][0],
                                       name: data[i][1]
                                   })
        }
        if ("id" in category) { //a fost setat obiectul din category list
            categoryTreeModel.append({
                                         id: category.id,
                                         name: category.name
                                     });
            pyconn({"sql": "SELECT product.product_id, `ean`, product.name, `price`, `tax_rate_id`, product_image.image FROM `product` JOIN product_image on product.image = product_image.product_image_id JOIN product_to_category on product.product_id = product_to_category.product_id JOIN category ON category.category_id = product_to_category.category_id WHERE product.status = 1 AND `favorite` = 1 AND product_to_category.selectable = 1 AND (category.category_id = " + category.id + " OR category.parent_id = " + category.id + ") ORDER BY product.sort_order"}, updateProducts);
        }
    } else if ("id" in category) {
        //query doar produsele din respectiva categorie intrucat este sfarsit de tree
        pyconn({"sql": "SELECT product.product_id, `ean`, `name`, `price`, `tax_rate_id`, product_image.image FROM `product` JOIN product_image on product.image = product_image.product_image_id JOIN product_to_category on product.product_id = product_to_category.product_id WHERE `status` = 1 AND `favorite` = 1 AND product_to_category.selectable = 1 AND product_to_category.category_id = " + category.id + " ORDER BY `sort_order`"}, updateProducts);
    }

    category = {};
}


function updateProducts(data) {
    produseModel.clear();
    for (var i = 0; i < data.length; i++) {
        //cauta daca produsele sunt deja in cos si schimba cantitatea
        var j = 0
        while (j < cosModel.count && data[i][0] !== cosModel.get(
                   j).id) {
            j++
        }
        var cantitate = 0;
        if (j !== cosModel.count) {
            cantitate = cosModel.get(
                        j).cantitate;
            console.warn(cantitate);
        } else {
            cantitate = 0;
        }

        produseModel.append({
                              id: data[i][0],
                              cod: data[i][1],
                              nume: data[i][2],
                              pret: data[i][3],
                              tva: data[i][4],
                              imagine: data[i][5] === undefined ? "prod_na.png" : data[i][5],
                              cant: cantitate
                          })
    }
}

function searchFunction() {
    if (stackView.currentItem.objectName === "") {
        if (search_string.length < 3) {
            //produseModel.clear();
            console.warn("urmeaza");
            console.warn(JSON.stringify(saved_product_list));
            console.warn("dupa");
            produseModel.clear();
            console.warn(JSON.stringify(saved_product_list));
            for (var key in saved_product_list) {
                console.warn(JSON.stringify(saved_product_list[key]))
                if (saved_product_list[key]['nume'].toLowerCase().match(search_string.toLowerCase())) {
                    produseModel.append(saved_product_list[key]);
                }
            }
        } else {
            if (isNaN(search_string)) {
                pyconn({"sql": "SELECT product.product_id, `ean`, product.name, `price`, `tax_rate_id`, product_image.image FROM `product` JOIN product_image on product.image = product_image.product_id WHERE product.status = 1 AND product.name LIKE '%" + search_string + "%' ORDER BY product.sort_order"}, updateProducts);
            } else {
                pyconn({"sql": "SELECT product.product_id, `ean`, product.name, `price`, `tax_rate_id`, product_image.image FROM `product` JOIN product_image on product.image = product_image.product_id WHERE product.status = 1 AND product.ean LIKE '" + search_string + "%' ORDER BY product.sort_order"}, updateProducts);
            }
        }
    }
}

function queryProducts (category_id) {
    pyconn({"sql": "SELECT product.product_id, `ean`, product.name, `price`, `tax_rate_id`, product_image.image FROM `product` JOIN product_image on product.image = product_image.product_id JOIN product_to_category on product.product_id = product_to_category.product_id JOIN category ON category.category_id = product_to_category.category_id WHERE product.status = 1 AND `favorite` = 1 AND product_to_category.selectable = 1 AND (category.category_id = " + category_id + " OR category.parent_id = " + category_id + ") ORDER BY product.sort_order"}, updateProducts)
}

function queryCategories(parent_id) {
    pyconn({"sql": "SELECT `category_id`, `name` FROM `category` WHERE top = 1 AND `status` = 1 AND  `parent_id` = " + parent_id + " ORDER BY `sort_order`"}, updateCategories);
}

function queryFavorites() {
    pyconn({"sql": "SELECT product.product_id, `ean`, `name`, `price`, `tax_rate_id`, product_image.image FROM `product` JOIN product_image on product.image = product_image.product_id WHERE `status` = 1 AND `favorite` = 1 ORDER BY `sort_order`"}, updateProducts);
}

function updateAll() {
    queryCategories(0);
    queryFavorites();
}

/*
                } else if (parseInt(r[0]) === 1) {
                    produseModel.append({
                                            categorie: parseInt(r[1]),
                                            id: parseInt(r[2]),
                                            cod: parseInt(r[3]),
                                            nume: r[4],
                                            pret: parseFloat(r[5]),
                                            tva: parseInt(r[6]),
                                            imagine: r[7],
                                            vanzari: parseInt(r[8]),
                                            cant: 0
                                        })
                    if (parseInt(r[8]) !== 0) {
                        produseModel.append({
                                              id: parseInt(r[2]),
                                              cod: parseInt(r[3]),
                                              nume: r[4],
                                              pret: parseFloat(r[5]),
                                              tva: parseInt(r[6]),
                                              imagine: r[7],
                                              cant: 0,
                                              index_prod: counter_prod,
                                              by_search: false
                                          })
                    }
                    counter_prod++
                } else if (parseInt(r[0]) === 2) {
                    tva_arr += "id" + r[1] + ";" + r[2] + ";";
                }
            }
            tva_arr.slice(0, -1);
        }
    }
    xhr.send()*/

function digitPressed(digit) {
  if (isNaN(digit)) {
    if (digit === '=') {
      console.log(cod_tastat)
      var i = 0
      while (i < cosModel.count && parseInt(
          cod_tastat) !== cosModel.get(i).cod) {
        i++
      }
      if (i === cosModel.count) {
        var req = "http://192.168.10.200/functions/produs.php?cod=" + cod_tastat
        var xhr = new XMLHttpRequest
        xhr.open("GET", req, true)

        xhr.onreadystatechange = function() {
          if (xhr.readyState === XMLHttpRequest.DONE) {
            var records = xhr.responseText.split(';')
            if (parseInt(records[0]) === 0) {
              cosModel.insert(0, {
                id: parseInt(records[1]),
                cod: parseInt(records[2]),
                nume: records[3],
                pret: parseFloat(records[4]),
                tva: parseInt(records[5]),
                cantitate: 1,
                unitate: records[6]
              })
              listview1.currentIndex = 0
              calc_total()
              General.lcd(1)
            }
          }
        }
        xhr.send()
      } else {
        General.playback('sounds-1049-knob')
        var cant_current = cosModel.get(i).cantitate
        cosModel.set(i, {
          cantitate: cant_current + 1
        })
        listview1.currentIndex = i
        string_cantitate = cant_current + 1
      }

      cod_tastat = ""
    }
  } else {
    cod_tastat = cod_tastat + digit
    cod_text.text = cod_tastat
  }
}

function calc_total() {
  var sum_total = 0
  var i
  sum_total = 0
  for (i = 0; i < cosModel.count; i++) {
    sum_total += cosModel.get(i).pret * cosModel.get(i).cantitate
  }
  total = sum_total.toFixed(2)
}

function keys_calc(tasta) {
  General.playback('sounds-1049-knob')
  if (cosModel.count > 0) {
    if (selectie_mod === "Cnt") {
      if (isNaN(tasta)) {
        if (tasta === 'del') {
          if (string_cantitate == "0") {
            cosModel.remove(listview1.currentIndex) //sterge daca actuala cantitate este 0
            return
          } else {
            if (string_cantitate.length === 1)
              string_cantitate = 0
            else
              string_cantitate = string_cantitate.slice(0, -1)
          }
        } else if (tasta === '.') {
          if (string_cantitate.indexOf('.') === -1) {
            string_cantitate = string_cantitate + tasta
          }
        } else if (tasta === '+/-') {
          if (string_cantitate.substr(0, 1) === "-")
            string_cantitate = string_cantitate.substring(1)
          else
            string_cantitate = '-' + string_cantitate
        }
      } else {
        if (produs_curent == false && string_cantitate !== "0") {
          string_cantitate = string_cantitate + tasta
        } else {
          string_cantitate = tasta
          produs_curent = false
        }
      }
      //####### PRET #######
    } else if (selectie_mod === "Pret") {
      if (isNaN(tasta)) {
        if (tasta === 'del') {
          if (string_pret.length === 1)
            string_pret = 0
          else
            string_pret = string_pret.slice(0, -1)
        } else if (tasta === '.') {
          if (string_pret.indexOf('.') === -1) {
            string_pret = string_pret + tasta
          }
        }
      } else {
        if (produs_curent == false && string_pret !== "0") {
          string_pret = string_pret + tasta
        } else {
          string_pret = tasta
          produs_curent = false
        }
      }
    }
    cosModel.set(listview1.currentIndex, {
      pret: parseFloat(string_pret)
    })
    cosModel.set(listview1.currentIndex, {
      cantitate: parseFloat(string_cantitate)
    })
    /*        if (cosModel.get(listview1.currentIndex).index_prod !== undefined) {

                var j = 0
                while (j < produseModel.count && cosModel.get(
                           listview1.currentIndex).index_prod !== produseModel.get(
                           j).index_prod) {
                    j++
                }
                if (j !== produseModel.count) {
                    produseModel.set(j, {
                                       cant: parseInt(string_cantitate)
                                   })
                }

                produseModel.set(cosModel.get(listview1.currentIndex).index_prod, {
                                     cant: parseInt(string_cantitate)
                                 })
            }*/
  }

  //####### COD #######
  if (selectie_mod === "Cod") {
    if (isNaN(tasta)) {
      if (tasta === 'del') {
        if (cod_keypad.length > 0) {
          cod_keypad = cod_keypad.slice(0, -1)
          cod_text.text = cod_keypad
        }
      }
    } else {
      var req = "http://192.168.10.200/functions/cauta_produs.php?cod=" + cod_keypad + tasta
      var xhr = new XMLHttpRequest
      xhr.open("GET", req, true)

      xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.DONE) {
          var records = xhr.responseText.split(';')
          if (parseInt(records[0]) === 0) {
            var i = 0
            while (i < cosModel.count && parseInt(
                records[1]) !== cosModel.get(i).id) {
              i++
            }
            if (i === cosModel.count) {
              cosModel.insert(0, {
                id: parseInt(records[1]),
                cod: parseInt(records[2]),
                nume: records[3],
                pret: parseFloat(records[4]),
                cantitate: 1,
                unitate: records[6],
                tva: parseInt(records[5])
              })
              listview1.currentIndex = 0
              PosEngine.calc_total()
              General.lcd(1)
            } else {
              var cant_current = cosModel.get(i).cantitate
              cosModel.set(i, {
                cantitate: cant_current + 1
              })
              listview1.currentIndex = i
              string_cantitate = cant_current + 1
            }
            cod_keypad = ""
            selectie_mod = "Cnt"
          } else if (parseInt(records[0]) !== 3) {
            cod_keypad = cod_keypad + tasta
            cod_text.text = cod_keypad
          }
        }
      }
      xhr.send()
    }
  }
}
