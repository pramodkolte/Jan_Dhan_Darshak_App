import 'package:flutter/material.dart';
import 'package:jan_dhan_darshak/services/bloc.dart';

class FavoritePlaces extends StatefulWidget {
  @override
  _FavoritePlacesState createState() => _FavoritePlacesState();
}

class _FavoritePlacesState extends State<FavoritePlaces> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Favourite Places',
          style: TextStyle(
            color: Colors.grey[700],
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Colors.grey[700],
        ),
      ),
      body: StreamBuilder(
        stream: favourites.getStream,
        initialData: favourites.favorites,
        builder: (context, snapshot) {
          print(snapshot.data.length);
          return snapshot.data.length > 0
              ? ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, i) {
                    final ftp = snapshot.data;
                    return ListTile(
                      title: Text(ftp[i].name),
                      subtitle: Text(ftp[i].address),
                      trailing: IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          favourites.removeFromFavorites(ftp[i]);
                        },
                      ),
                      onTap: () {},
                    );
                  })
              : Center(child: Text("Your favourite places list is empty"));
        },
      ),
    );
  }
}
