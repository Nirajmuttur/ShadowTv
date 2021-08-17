import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:localstorage/localstorage.dart';
import 'package:movieapp/Pages/SeasonDetail.dart';
import 'package:movieapp/models/series.dart';
import 'package:movieapp/networkUtils/seriesAPICalls.dart';

class SeriesDetail extends StatefulWidget {
  var title, desc, imgsrc;
  SeriesDetail({this.title, this.desc, this.imgsrc});
  @override
  _SeriesDetailState createState() => _SeriesDetailState();
}

class _SeriesDetailState extends State<SeriesDetail> {
  Network networkHandler = new Network();
  static LocalStorage storage3 = new LocalStorage('RecentlyViewed');
  var data;
  bool load1 = true;
  bool internet = true;
  @override
  void initState() {
    super.initState();
    getSeriesDetail();
    getRecentlyViewed();
  }

  @override
  void dispose() {
    super.dispose();
    getSeriesDetail();
    getRecentlyViewed();
  }

  void getRecentlyViewed() async {
    await storage3.ready;
    List<Series> data1 = [
      Series(title: widget.title, desc: widget.desc, imgsrc: widget.imgsrc)
    ];
    String jsonTags = jsonEncode(data1);
    storage3.setItem('RecentlyViewed', jsonTags);
  }

  void getSeriesDetail() async {
    try {
      final response = await networkHandler
          .getSeriesDetail("/api/getSeason?movieName=${widget.title}");
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
                              _imageScroll(context),
                              _season(context),
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
              imageUrl: "http://url/${widget.imgsrc}",
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
                        imageUrl: "http://url/${widget.imgsrc}",
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
                        Text('Year${data['Description'][1]}',
                            style: TextStyle(color: Colors.grey, fontSize: 12)),
                        SizedBox(height: 5),
                        Text(
                          'IMBDRating${data['Description'][3]}',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Genre${data['Description'][2]}',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
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
            '${data['Description'][0]}',
            style: TextStyle(fontSize: 16, color: Colors.white),
          )
        ],
      ),
    );
  }

  Widget _imageScroll(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
        height: 20.0,
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child:
            Text('Photos', style: TextStyle(color: Colors.grey, fontSize: 15)),
      ),
      SizedBox(
        height: 15,
      ),
      SizedBox.fromSize(
        size: const Size.fromHeight(100.0),
        child: ListView.builder(
          itemCount: data['Img'].length,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(top: 8.0, left: 20.0),
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () async {
                showDialog(
                    context: context,
                    builder: (_) => _imagepopup(context, data['Img'][index]));
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(4.0),
                    child: CachedNetworkImage(
                        placeholder: (context, url) {
                          return Image.asset('assets/logo.jpg');
                        },
                        errorWidget: (context, url, error) {
                          return Image.asset('assets/logo.jpg');
                        },
                        imageUrl: "http://url/${data['Img'][index]}",
                        width: 160.0,
                        height: 150.0,
                        fit: BoxFit.cover)),
              ),
            );
          },
        ),
      ),
    ]);
  }

  Widget _season(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 30,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text('Seasons',
              style: TextStyle(color: Colors.grey, fontSize: 15)),
        ),
        SizedBox(
          height: 10,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                mainAxisExtent: 200,
                crossAxisCount: 3,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
              ),
              itemCount: data['Season'].length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SeasonDetail(
                                url: data['URL'][index],
                                season: data['Season'][index])));
                  },
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    elevation: 1,
                    color: Colors.transparent,
                    child: Center(
                      child: Stack(children: [
                        CachedNetworkImage(
                          placeholder: (context, url) {
                            return Image.asset('assets/logo.jpg');
                          },
                          imageUrl: "http://url/${widget.imgsrc}",
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) {
                            return Image.asset('assets/logo.jpg');
                          },
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text('${data['Season'][index]}',
                                textAlign: TextAlign.justify,
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white)),
                          ],
                        ),
                      ]),
                    ),
                  ),
                );
              }),
        ),
      ],
    );
  }

  Widget _imagepopup(BuildContext context, String url) {
    return Dialog(
      child: Container(
        width: 900,
        height: 250,
        child: CachedNetworkImage(
          placeholder: (context, url) {
            return Image.asset('assets/logo.jpg');
          },
          errorWidget: (context, url, error) {
            return Image.asset('assets/logo.jpg');
          },
          imageUrl: "http://url/${url}",
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
