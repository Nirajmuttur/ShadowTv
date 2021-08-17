import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:movieapp/networkUtils/seriesAPICalls.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:toast/toast.dart';

class EpisodeDetail extends StatefulWidget {
  String title, imgsrc, desc, file;
  int index;
  EpisodeDetail({this.title, this.imgsrc, this.desc, this.file, this.index});
  @override
  _EpisodeDetailState createState() => _EpisodeDetailState();
}

class _EpisodeDetailState extends State<EpisodeDetail> {
  Network networkHandler = new Network();
  var data;
  bool load = true;
  bool internet = true;
  int progress = 0;
  bool downloadToast = false;

  ReceivePort _receivePort = ReceivePort();

  static downloadingCallback(id, status, progress) {
    ///Looking up for a send port
    SendPort sendPort = IsolateNameServer.lookupPortByName("downloading");

    ///ssending the data
    sendPort.send([id, status, progress]);
  }

  @override
  void initState() {
    super.initState();
    IsolateNameServer.registerPortWithName(
        _receivePort.sendPort, "downloading");

    ///Listening for the data is comming other isolataes
    // _receivePort.listen((message) {
    //   setState(() {
    //     progress = message[2];
    //   });
    // });

    FlutterDownloader.registerCallback(downloadingCallback);
    getEpisodeDetail();
  }

  void getEpisodeDetail() async {
    try {
      final response = await networkHandler.getEpisodeDetail(
          "/api/getEpisodeDetail", widget.file);
      data = json.decode(response.body);
      setState(() {
        load = false;
      });
    } on SocketException catch (_) {
      setState(() {
        internet = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff222831),
      appBar: AppBar(
        backgroundColor: Colors.black12,
        title: Text('${widget.title}'),
      ),
      body: internet
          ? load
              ? Center(
                  child: SpinKitWave(
                  color: Colors.white,
                  size: 20.0,
                ))
              : SafeArea(
                  child: Stack(
                    children: [
                      SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          child: ListView(
                            padding: EdgeInsets.only(top: 30),
                            children: <Widget>[
                              _buildInfoRow(context),
                              _buildDescriptionRow(context),
                              _downloadLink(context),
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
        padding: EdgeInsets.fromLTRB(12, 1, 6, 4),
        child: Stack(
          alignment: Alignment.centerLeft,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                    width: 180,
                    height: 200,
                    child: CachedNetworkImage(
                        errorWidget: (context, url, error) {
                          return Image.asset('assets/logo.jpg');
                        },
                        imageUrl: "http://url/${widget.imgsrc}",
                        fit: BoxFit.fill)),
                SizedBox(width: 10),
                SizedBox(
                    width: 150,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('  Episode ${widget.index + 1}',
                            style: TextStyle(
                                fontWeight: FontWeight.w200,
                                fontSize: 15,
                                color: Colors.white)),
                        Text('${widget.title}',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 26,
                                color: Colors.white)),
                        SizedBox(height: 30),
                      ],
                    )),
              ],
            ),
          ],
        ));
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
            '${widget.desc}',
            style: TextStyle(fontSize: 16, color: Colors.white),
          )
        ],
      ),
    );
  }

  Widget _downloadLink(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 30,
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
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text('FileName: ${data['FileName'][0]}',
              maxLines: 2, style: TextStyle(fontSize: 16, color: Colors.white)),
        ),
        SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text('Size: ${data['Size'][0]}',
              maxLines: 2, style: TextStyle(fontSize: 16, color: Colors.white)),
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
              itemCount: data['Link'].length,
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
                                  url: data['Link'][index],
                                  savedDir: externalDir.path,
                                  fileName: data['FileName'][0],
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
                                ClipboardData(text: "${data['Link'][index]}"));
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
