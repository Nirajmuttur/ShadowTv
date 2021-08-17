import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:movieapp/networkUtils/movieAPICalls.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:toast/toast.dart';

class MovieDetail extends StatefulWidget {
  String title, img, desc, file;
  MovieDetail({this.img, this.title, this.desc, this.file});

  @override
  _MovieDetailState createState() => _MovieDetailState();
}

class _MovieDetailState extends State<MovieDetail> {
  MovieNetwork networkHandler = new MovieNetwork();
  var data;
  bool load1 = true;
  bool internet = true;
  bool downloadToast = false;

  @override
  void initState() {
    super.initState();
    getMovieDetail();
  }

  void getMovieDetail() async {
    try {
      final response = await networkHandler.getMovieDetail(
          "/api/movies/movieDetail", widget.file);
      data = json.decode(response.body);
      if (mounted) {
        setState(() {
          load1 = false;
        });
      }
    } on SocketException catch (_) {
      setState(() {
        internet = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var topImageHeight = MediaQuery.of(context).size.width * 0.7;
    return Scaffold(
      backgroundColor: Color(0xff222831),
      appBar: AppBar(
        backgroundColor: Colors.black12,
        title: Text('${widget.title}'),
      ),
      body: internet
          ? load1
              ? Center(
                  child: SpinKitWave(
                  color: Colors.white,
                  size: 20.0,
                ))
              : SafeArea(
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.topCenter,
                        child: _buildImageView(
                            context: context, height: topImageHeight),
                      ),
                      SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          child: ListView(
                            padding: EdgeInsets.only(top: 30),
                            children: <Widget>[
                              _buildInfoRow(context),
                              _buildDescriptionRow(context),
                              _buildDownloadLinks(context)
                            ],
                          ))
                    ],
                  ),
                )
          : Center(
              child: Text(
                'Please Check Your Internet Connection!',
                style: TextStyle(color: Colors.white),
              ),
            ),
    );
  }

  Widget _buildInfoRow(BuildContext context) {
    return Container(
        padding: EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Stack(
          alignment: Alignment.centerLeft,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                    width: 124,
                    height: 180,
                    child: CachedNetworkImage(
                        errorWidget: (context, url, error) {
                          return Image.asset('assets/logo.jpg');
                        },
                        placeholder: (context, url) {
                          return Image.asset('assets/logo.jpg');
                        },
                        imageUrl: "http://url/${widget.img}",
                        fit: BoxFit.cover)),
                SizedBox(width: 10),
                SizedBox(
                    width: 200,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('${widget.title}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 26,
                                color: Colors.white)),
                        SizedBox(height: 30),
                        Text('Date: ${data['Properties'][0]}',
                            style: TextStyle(color: Colors.grey, fontSize: 15)),
                        SizedBox(height: 5),
                        Text(
                          'Duration: ${data['Properties2'][0]}',
                          style: TextStyle(color: Colors.grey, fontSize: 15),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Genre: ${data['Properties3']}',
                          style: TextStyle(color: Colors.grey, fontSize: 15),
                        ),
                      ],
                    )),
              ],
            ),
          ],
        ));
  }

  Widget _buildImageView({BuildContext context, double height}) {
    return SizedBox(
        child: Stack(children: <Widget>[
      Container(
          height: height,
          width: MediaQuery.of(context).size.width,
          child: CachedNetworkImage(
              errorWidget: (context, url, error) {
                return Image.asset('assets/logo.jpg');
              },
              imageUrl: "http://url/${widget.img}",
              placeholder: (context, url) {
                return Center(
                    child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.grey))));
              },
              fit: BoxFit.cover)),
      SizedBox.expand(
          child: Container(
              height: 300,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.center,
                      stops: [0.5, 1.0],
                      colors: [Colors.black38, Color(0xff26262d)])))),
    ]));
  }

  Widget _buildDescriptionRow(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 45,
          ),
          Text('Description',
              style: TextStyle(color: Colors.grey, fontSize: 15)),
          SizedBox(
            height: 15,
          ),
          Text(
            '${data['Description'][0]}',
            style: TextStyle(fontSize: 16, color: Colors.white),
          )
        ],
      ),
    );
  }

  Widget _buildDownloadLinks(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 15,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text('Download',
              style: TextStyle(color: Colors.grey, fontSize: 15)),
        ),
        SizedBox(
          height: 10,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: data['file'].length,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  color: Color(0xff222831),
                  child: Row(
                    children: [
                      Expanded(
                        child: RaisedButton(
                          onPressed: () async {
                            final status = await Permission.storage.request();
                            if (status.isGranted) {
                              Directory externalDir =
                                  await getExternalStorageDirectory();
                              String newPath = '';
                              List<String> folders =
                                  externalDir.path.split('/');
                              for (int x = 1; x < folders.length; x++) {
                                String folder = folders[x];
                                if (folder != "Android") {
                                  newPath += "/" + folder;
                                } else {
                                  break;
                                }
                              }
                              newPath = newPath + '/SeriesApp';
                              externalDir = Directory(newPath);
                              if (!await externalDir.exists()) {
                                await externalDir.create(recursive: true);
                              }
                              final id = await FlutterDownloader.enqueue(
                                  url: data['file'][index],
                                  savedDir: externalDir.path,
                                  fileName: widget.title,
                                  showNotification: true,
                                  openFileFromNotification: true);
                              setState(() {
                                downloadToast = true;
                              });
                              _toast(context);
                            } else {}
                          },
                          child: Text(
                            "Download ${index + 1}",
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: RaisedButton(
                          child: Text("Copy Link ${index + 1}"),
                          onPressed: () {
                            Clipboard.setData(
                                ClipboardData(text: "${data['file'][index]}"));
                            setState(() {
                              downloadToast = false;
                            });
                            _toast(context);
                          },
                        ),
                      )
                    ],
                  ),
                );
              }),
        ),
      ],
    );
  }

  _toast(BuildContext context) {
    return downloadToast
        ? Toast.show("Added to Downloads", context,
            duration: Toast.LENGTH_LONG,
            gravity: Toast.CENTER,
            textColor: Colors.white)
        : Toast.show("Link Added to Clipboard", context,
            duration: Toast.LENGTH_LONG,
            gravity: Toast.CENTER,
            textColor: Colors.white);
  }
}
