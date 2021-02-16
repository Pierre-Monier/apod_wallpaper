import 'dart:convert';

import 'package:apod_wallpaper/models/apod_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
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

  Future<Apod> _fetchApi() async {
    final test = await _dio.get(apiUrl);
    final jsonTest = jsonDecode(test.toString());
    return Apod.fromJson(Map<String, dynamic>.from(jsonTest));
  }

  Future<void> _setHasWallpaper() async {
    print("TODO");
  }

  YoutubePlayerController _getVideoController({@required String videoId}) {
    return YoutubePlayerController(
      initialVideoId: videoId,
      flags: YoutubePlayerFlags(
        autoPlay: false,
      ),
    );
  }

  Widget _getMainContent({@required Apod apod}) {
    return apod.isImage() ? Image.network(
        apod.url,
        loadingBuilder: (context, child, progress) {
          return progress == null ? child : CircularProgressIndicator(
            value: progress.cumulativeBytesLoaded / progress.expectedTotalBytes,
          );
        }
    ) : YoutubePlayer(controller: _getVideoController(videoId: YoutubePlayer.convertUrlToId(apod.url)),);
  }

  Column _formatData({@required Apod snapshot}) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(20),
        child: Text.rich(
          TextSpan(
            text: snapshot.date + ": ",
            children: <TextSpan>[
              TextSpan(text: snapshot.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
            ],
          ),
        ),
      ),
      _getMainContent(apod: snapshot),
      Padding(padding: const EdgeInsets.all(20),
      child: Text(snapshot.explanation))
    ]);
  }

  Container _formatError() {
    return Container(child: Icon(Icons.addchart));
  }

  Container _formatLoading() {
    return Container(child: CircularProgressIndicator());
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: SingleChildScrollView(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FutureBuilder<Apod>(
              future: _fetchApi(),
              builder: (BuildContext context, AsyncSnapshot<Apod> snapshot) {
                Widget childrenTest;
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
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: _setHasWallpaper,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}

// TODO when you click on image, fullsize image
// TODO Background functionnality on float btn