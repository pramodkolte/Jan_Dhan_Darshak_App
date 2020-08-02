import 'dart:async';

import 'package:jan_dhan_darshak/services/models.dart';

class Favorites {
  final favoritesStreamController = StreamController.broadcast();

  Stream get getStream => favoritesStreamController.stream;

  final List<Ftp> favorites = [];

  void addToFavorites(Ftp item) {
    print('Favorite added');
    favorites.add(item);
    favoritesStreamController.sink.add(favorites);
  }

  void removeFromFavorites(Ftp item) {
    print('Favorite removed');
    favorites.remove(item);
    favoritesStreamController.sink.add(favorites);
  }

  void dispose() {
    favoritesStreamController.close();
  }
}

final favourites = Favorites();
