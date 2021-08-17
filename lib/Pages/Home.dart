import 'dart:convert';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:movieapp/Pages/GenreMore.dart';
import 'package:movieapp/Pages/SeriesDetail.dart';
import 'package:movieapp/Pages/Slider.dart';
import 'package:movieapp/networkUtils/seriesAPICalls.dart';
import 'Slider.dart';
import 'package:localstorage/localstorage.dart';

class HomePage extends StatefulWidget {
  final String currentUserId;
  HomePage({this.currentUserId});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Network networkHandler = new Network();
  LocalStorage storage;
  bool load1 = true;
  bool load2 = true;
  var data, data2, data3;
  bool recent = false;
  List<int> numberList = [];
  @override
  void initState() {
    super.initState();
    getUpdate();
    getListByGenre();
    recentlyViewedCache();
  }

  List<int> generateRandomNumber() {
    Random random = new Random();
    for (var i = 0; i <= 20; i++) {
      int random_number = random.nextInt(20);
      if (!numberList.contains(random_number)) {
        numberList.add(random_number);
      }
    }
    return numberList;
  }

  String slice(String name) {
    String modifiedName = name.replaceAll(' ', '.');
    return modifiedName;
  }

  void getUpdate() async {
    try {
      data = await networkHandler.getLatestSeries();
      setState(() {
        load1 = false;
      });
    } catch (e) {
      print(e);
    }
  }

  Future recentlyViewedCache() async {
    try {
      data3 = json.decode(await networkHandler.getRecentlyViewedFromCache());
      if (data3 == null) {
        setState(() {
          recent = true;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  void getListByGenre() async {
    try {
      data2 = await networkHandler.getSeriesByGenre();
      setState(() {
        load2 = false;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black12,
        title: Text('Shadow TV'),
      ),
      backgroundColor: Color(0xff222831),
      body: load2
          ? Center(
              child: SpinKitWave(
              color: Colors.white,
              size: 20.0,
            ))
          : RefreshIndicator(
              onRefresh: recentlyViewedCache,
              child: ListView(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.width * 0.6,
                    child: SHome(
                      Movie: false,
                    ),
                  ),
                  Column(
                    children: [
                      recent
                          ? _recentlyViewed(data3, 'Recently Viewed')
                          : Text(''),
                      _buildRowView(data[0], 'Popular Shows'),
                      _buildRowView(data2['Movies'][0], 'Action'),
                      _buildRowView(data2['Movies'][1], 'Adventure'),
                      _buildRowView(data2['Movies'][2], 'Romance'),
                      _buildRowView(data2['Movies'][3], 'Comedy'),
                      _buildRowView(data2['Movies'][4], 'Thriller'),
                    ],
                  )
                ],
              ),
            ),
    );
  }

  Widget _recentlyViewed(var data, String name) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 52,
          child: Stack(
            children: [
              Align(
                  alignment: Alignment.centerLeft,
                  child: Text('${name}',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold))),
              Align(
                  alignment: Alignment.centerRight,
                  child: MaterialButton(
                    minWidth: 20,
                    child: Icon(Icons.more_horiz),
                    onPressed: () {
                      PopupMenuButton(
                          icon: Icon(Icons.more_vert),
                          itemBuilder: (BuildContext context) =>
                              <PopupMenuEntry>[
                                const PopupMenuItem(
                                  child: ListTile(
                                    leading: Icon(Icons.add),
                                    title: Text('Item 1'),
                                  ),
                                ),
                              ]);
                    },
                  ))
            ],
          ),
        ),
      ),
      Container(
          height: 250,
          child: Container(
              width: MediaQuery.of(context).size.width,
              //height: 250,
              child: ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SeriesDetail(
                                        title: data[index]['title'],
                                        desc: data[index]['desc'],
                                        imgsrc: data[index]['imgsrc'],
                                      )));
                        },
                        child: SizedBox(
                          width: 120,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CachedNetworkImage(
                                  imageUrl:
                                      "http://url/${data[index]['imgsrc']}",
                                  errorWidget: (context, url, error) {
                                    return Image.asset('assets/logo.jpg');
                                  },
                                  placeholder: (context, url) {
                                    return Image.asset('assets/logo.jpg');
                                  },
                                  fit: BoxFit.cover),
                              SizedBox(height: 14),
                              Text('${data[index]['title']}',
                                  maxLines: 2,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.white))
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  padding: EdgeInsets.only(left: 16.0),
                  scrollDirection: Axis.horizontal,
                  physics: BouncingScrollPhysics())))
    ]);
  }

  Widget _buildRowView(var data, String name) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 52,
          child: Stack(
            children: [
              Align(
                  alignment: Alignment.centerLeft,
                  child: Text('${name}',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold))),
              Align(
                  alignment: Alignment.centerRight,
                  child: PopupMenuButton(
                    icon: Icon(
                      Icons.more_horiz,
                      color: Colors.white,
                    ),
                    color: Color(0xff222831),
                    itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                      const PopupMenuItem(
                        value: '1',
                        child: ListTile(
                          title: Text(
                            'View More',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == '1') {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => GenreMore(
                                      data: data,
                                      name: name,
                                    )));
                      }
                    },
                  ))
            ],
          ),
        ),
      ),
      Container(
          height: 250,
          child: Container(
              width: MediaQuery.of(context).size.width,
              //height: 250,
              child: ListView.builder(
                  itemCount: data['titles'].length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SeriesDetail(
                                        title: data['titles']
                                            [generateRandomNumber()[index]],
                                        desc: data['desp']
                                            [generateRandomNumber()[index]],
                                        imgsrc: data['img']
                                            [generateRandomNumber()[index]],
                                      )));
                        },
                        child: SizedBox(
                          width: 120,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CachedNetworkImage(
                                  imageUrl:
                                      "http://url/${data['img'][generateRandomNumber()[index]]}",
                                  placeholder: (context, url) {
                                    return AspectRatio(
                                      aspectRatio: 0.68,
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  },
                                  errorWidget: (context, url, error) =>
                                      new Icon(Icons.error),
                                  fit: BoxFit.cover),
                              SizedBox(height: 14),
                              Text(
                                  '${data['titles'][generateRandomNumber()[index]]}',
                                  maxLines: 2,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.white))
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  padding: EdgeInsets.only(left: 16.0),
                  scrollDirection: Axis.horizontal,
                  physics: BouncingScrollPhysics())))
    ]);
  }
}
