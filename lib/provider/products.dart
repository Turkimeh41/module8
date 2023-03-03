import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'product.dart';

class Products with ChangeNotifier {
  final String token;
  final String currentUserID;
  List<Product> _products = [];
  List<Product> _uProducts = [];
  Products(this.token, this.currentUserID, this._products);

  List<Product> get products {
    return [..._products];
  }

  List<Product> get favproducts {
    return _products.where((product) => product.isFavourite == true).toList();
  }

  List<Product> get userproducts {
    _uProducts = _products.where((product) => product.uid == currentUserID).toList();
    return [..._uProducts];
  }

  Future<void> addProduct({required, required title, required description, required imageURL, required price, favorite = false}) async {
    final urlProducts = Uri.parse('https://new-project-ebe4a-default-rtdb.europe-west1.firebasedatabase.app/products.json?auth=$token');
    try {
      final response = await http.post(urlProducts, body: json.encode({'title': title, 'description': description, 'imageUrl': imageURL, 'price': price, 'uid': currentUserID}));
      _products.add(
          Product(id: json.decode(response.body)['name'], uid: currentUserID, title: title, description: description, imageURL: imageURL, price: price, isFavourite: favorite));
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> fetchProductsAndSET() async {
    final List<Product> loadedProducts = [];
    try {
      final urlProducts = Uri.parse('https://new-project-ebe4a-default-rtdb.europe-west1.firebasedatabase.app/products.json?auth=$token');
      final response = await http.get(urlProducts);
      final extracted = json.decode(response.body);
      if (extracted == null) {
      } else {
        final urlUserFav = Uri.parse('https://new-project-ebe4a-default-rtdb.europe-west1.firebasedatabase.app/userfavorites/$currentUserID.json?auth=$token');
        final favoriteresponse = await http.get(urlUserFav);
        final favoriteData = json.decode(favoriteresponse.body);

        final extracted = json.decode(response.body) as Map<String, dynamic>;
        extracted.forEach((pID, value) {
          loadedProducts.add(Product(
              id: pID,
              uid: value['uid'],
              title: value['title'],
              description: value['description'],
              imageURL: value['imageUrl'],
              price: value['price'],
              isFavourite: favoriteData[pID]));
        });
      }
    } catch (error) {
      rethrow;
    } finally {
      _products = loadedProducts;
      notifyListeners();
    }
  }

  Product findByID(String id) {
    return _products.firstWhere((element) {
      return element.id == id;
    });
  }

  Future<void> removeProduct(String id) async {
    final urlProduct = Uri.parse('new-project-ebe4a-default-rtdb.europe-west1.firebasedatabase.app/products/$id.json?auth=$token');
    for (int i = 0; i < _products.length; i++) {
      if (id == _products[i].id) {
        try {
          await http.delete(urlProduct);
          _products.removeAt(i);
        } catch (error) {
          rethrow;
        }
      }
    }
    notifyListeners();
  }
}
