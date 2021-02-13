import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';

void main() async {
  await DotEnv().load('.env');
  final apiUrl = DotEnv().env['API_URL'];
  runApp(MyApp(apiUrl: apiUrl));
}

class MyApp extends StatelessWidget {
  MyApp({Key key, this.apiUrl}) : super(key: key);
  final String apiUrl;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(apiUrl: apiUrl,)
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key key, @required this.apiUrl}) : super(key: key);
  final String apiUrl;
  final title = "APOD WALLPAPER";
  final _dio = Dio();

  Future<Map<String, dynamic>> fetchApi() async {
    final test = await _dio.get(apiUrl);
    final jsonTest = jsonDecode(test.toString());
    return Map<String, dynamic>.from(jsonTest);
  }

  Future<void> _setHasWallpaper() async {
    await fetchApi();
  }

  Column _formatData({@required Map<String, dynamic> snapshot}) {
    return Column(children: [
      Text(snapshot["date"] + " : " +snapshot["title"]),
      Image.network(
        snapshot["url"],
        loadingBuilder: (context, child, progress) {
          return progress == null ? child : CircularProgressIndicator(
            value: progress.cumulativeBytesLoaded / progress.expectedTotalBytes,
          );
        }
      ),
      Text(snapshot["explanation"])
    ]);
  }

  Column _formatError() {
    return Column(children: [Icon(Icons.addchart)]);
  }

  Column _formatLoading() {
    return Column(children: [CircularProgressIndicator()]);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FutureBuilder<Map<String, dynamic>>(
              future: fetchApi(),
              builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
                Column childrenTest;
                if (snapshot.hasData) {
                  childrenTest = _formatData(snapshot: snapshot.data);
                } else if (snapshot.hasError) {
                  childrenTest = _formatError();
                } else {
                  childrenTest = _formatLoading();
                }

                return childrenTest;
              },
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _setHasWallpaper,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}

// TODO Model implementation
// TODO when you click on image, fullsize image
// TODO Better design
// TODO Background functionnality on float btn