import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class Photo {
  final int id;
  final String title;
  final String url;
  final String thumbnailUrl;

  Photo({required this.id, required this.title, required this.url, required this.thumbnailUrl});
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo Viewer',
      home: PhotoList(),
    );
  }
}

class PhotoList extends StatefulWidget {
  @override
  _PhotoListState createState() => _PhotoListState();
}

class _PhotoListState extends State<PhotoList> {
  late Future<List<Photo>> photos;

  @override
  void initState() {
    super.initState();
    photos = fetchPhotos();
  }

  Future<List<Photo>> fetchPhotos() async {
    final response = await http.get(Uri.https('jsonplaceholder.typicode.com', '/photos'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => Photo(
        id: item['id'],
        title: item['title'],
        url: item['url'],
        thumbnailUrl: item['thumbnailUrl'],
      )).toList();
    } else {
      throw Exception('Failed to load photos');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Photo Viewer'),
      ),
      body: FutureBuilder<List<Photo>>(
        future: photos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading photos'));
          } else {
            final List<Photo> photoList = snapshot.data!;
            return ListView.builder(
              itemCount: photoList.length,
              itemBuilder: (context, index) {
                final photo = photoList[index];
                return ListTile(
                  title: Text(photo.title),
                  leading: Image.network(photo.thumbnailUrl),
                );
              },
            );
          }
        },
      ),
    );
  }
}
