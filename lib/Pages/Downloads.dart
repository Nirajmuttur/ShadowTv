import 'dart:isolate';
import 'dart:ui';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:toast/toast.dart';

class Downloads extends StatefulWidget {
  @override
  _DownloadsState createState() => _DownloadsState();
}

class _DownloadsState extends State<Downloads> {
  SendPort sendPort = IsolateNameServer.lookupPortByName("downloading");
  int progress = 0;
  ReceivePort _receivePort = ReceivePort();
  bool load = true;
  bool pause = false;
  String t;
  List<DownloadTask> tasks;
  void initState() {
    super.initState();
    _toast(BuildContext context) {
      return Toast.show("Drag to refresh", context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.BOTTOM,
          textColor: Colors.white);
    }

    getTaskId();
  }

  Future getTaskId() async {
    tasks = await FlutterDownloader.loadTasks();

    setState(() {
      load = false;
    });
  }

  Icon icon1 = new Icon(
    Icons.download_rounded,
    color: Colors.grey[850],
  );

  Icon icon2 = new Icon(
    Icons.download_done_sharp,
    color: Colors.grey[850],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xff222831),
        appBar: AppBar(
          backgroundColor: Colors.black12,
          title: Text('Downloads'),
        ),
        body: load
            ? Center(
                child: SpinKitWave(
                color: Colors.white,
                size: 20.0,
              ))
            : RefreshIndicator(
                onRefresh: getTaskId,
                child: tasks.length == 0
                    ? Center(
                        child: Text(
                          'No Downloads',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    : ListView.builder(
                        itemCount: tasks.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Card(
                            child: ListTile(
                              leading:
                                  tasks[index].progress == 100 ? icon2 : icon1,
                              title: Text(tasks[index].filename),
                              subtitle: tasks[index].progress == 100
                                  ? Text('Download Complete')
                                  : Text('${tasks[index].progress}%'),
                              trailing: tasks[index].progress != 100
                                  ? pause
                                      ? IconButton(
                                          icon: Icon(Icons.play_arrow),
                                          onPressed: () {
                                            setState(() {
                                              pause = false;
                                            });
                                            FlutterDownloader.resume(
                                                taskId: tasks[index].taskId);
                                          })
                                      : IconButton(
                                          icon: Icon(Icons.pause),
                                          onPressed: () {
                                            setState(() {
                                              pause = true;
                                            });
                                            FlutterDownloader.pause(
                                                taskId: tasks[index].taskId);
                                          })
                                  : IconButton(
                                      icon: Icon(Icons.folder_open_sharp),
                                      onPressed: () async {
                                        OpenFile.open(
                                            tasks[index].savedDir +
                                                "/${tasks[index].filename}",
                                            type: "video/mp4");
                                      },
                                      color: Colors.grey[850],
                                    ),
                            ),
                          );
                        }),
              ));
  }
}
