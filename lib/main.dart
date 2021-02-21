import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:wallpaper_manager/wallpaper_manager.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:dio/dio.dart';

import 'package:apod_wallpaper/models/apod_model.dart';


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
  Apod _apod;

  Future<Apod> _getApodData() async {
    final test = await _dio.get(apiUrl);
    final jsonTest = jsonDecode(test.toString());
    final apod = Apod.fromJson(Map<String, dynamic>.from(jsonTest));
    
    _apod = apod;
    return apod;
  }

  Future<void> _setHasWallpaper(BuildContext context) async {
    final file = await DefaultCacheManager().getSingleFile(_apod.getWallpaperUrl());
    final String result = await WallpaperManager.setWallpaperFromFile(file.path, WallpaperManager.HOME_SCREEN);

    _showToast(result);
  }

  void _showToast(String result) {
    Fluttertoast.showToast(
        msg: result,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16.0
    );
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
    ) : YoutubePlayer(controller: _getVideoController(videoId: YoutubePlayer.convertUrlToId(apod.url)));
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
    return Container(child: Icon(Icons.signal_wifi_off ));
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
              future: _getApodData(),
              builder: (BuildContext context, AsyncSnapshot<Apod> snapshot) {
                Widget children;
                if (snapshot.hasData) {
                  children = _formatData(snapshot: snapshot.data);
                } else if (snapshot.hasError) {
                  children = _formatError();
                } else {
                  children = _formatLoading();
                }

                return children;
              },
            )
          ],
        ),
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _apod != null ? _setHasWallpaper(context) : _showToast("Wait for data"),
        tooltip: 'Increment',
        child: Icon(Icons.wallpaper),
      ),
    );
  }
}

// TODO when you click on image, full size image
// TODO change date feature
// TODO Background feature on float btn
// TODO customise the background setting (HomeScreen | LockScreen | Both)