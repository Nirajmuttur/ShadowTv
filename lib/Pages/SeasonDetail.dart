import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:movieapp/Pages/EpisodeDetail.dart';
import 'package:movieapp/networkUtils/seriesAPICalls.dart';

class SeasonDetail extends StatefulWidget {
  String url, season;
  SeasonDetail({this.url, this.season});
  @override
  _SeasonDetailState createState() => _SeasonDetailState();
}

class _SeasonDetailState extends State<SeasonDetail> {
  Network networkHandler = new Network();

  int episode = 0;
  var data;
  bool load = true;
  bool internet = true;
  @override
  void initState() {
    super.initState();
    getSeasonDetail();
  }

  void getSeasonDetail() async {
    try {
      final response = await networkHandler
          .getSeriesDetail("/api/getSeasonDetail?file=${widget.url}");
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

  List<String> slice(String name) {
    return name.split("-");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff222831),
      appBar: AppBar(
        backgroundColor: Colors.black12,
        title: Text('${widget.season}'),
      ),
      body: internet
          ? load
              ? Center(
                  child: SpinKitWave(
                  color: Colors.white,
                  size: 20.0,
                ))
              : GridView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    mainAxisExtent: 200,
                    crossAxisCount: 3,
                    crossAxisSpacing: 4.0,
                    mainAxisSpacing: 4.0,
                  ),
                  itemCount: data['Titles'].length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EpisodeDetail(
                                      title: slice(data['Titles'][index])[2],
                                      imgsrc: data['Images'][index],
                                      desc: data['Description'][index],
                                      file: data['File'][index],
                                      index: index,
                                    )));
                      },
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        child: Center(
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CachedNetworkImage(
                                errorWidget: (context, url, error) {
                                  return Image.asset('assets/logo.jpg');
                                },
                                placeholder: (context, url) {
                                  return Image.asset('assets/logo.jpg');
                                },
                                imageUrl: "http://url/${data['Images'][index]}",
                                fit: BoxFit.cover,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    'Episode ${index + 1}',
                                    style: TextStyle(color: Colors.white),
                                    maxLines: 2,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  })
          : Center(
              child: Text(
                'Please Check Your Internet Connection!',
                style: TextStyle(color: Colors.white),
              ),
            ),
    );
  }
}
