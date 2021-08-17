import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:localstorage/localstorage.dart';
import 'package:movieapp/Pages/Movie/MovieDetail.dart';
import 'package:movieapp/Pages/Slider.dart';
import 'package:movieapp/networkUtils/movieAPICalls.dart';

class MovieHome extends StatefulWidget {
  const MovieHome({Key key}) : super(key: key);

  @override
  _MovieHomeState createState() => _MovieHomeState();
}

class _MovieHomeState extends State<MovieHome> {
  MovieNetwork networkHandler = new MovieNetwork();
  LocalStorage storage;
  bool load1 = true;
  bool load2 = true;
  var data, data2, data3;
  bool recent = false;
  List<int> numberList = [];

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

  void getListByGenre() async {
    try {
      //final response = await networkHandler.getSeriesByGenre();
      data2 = await networkHandler.getMoviesByGenre();
      setState(() {
        load2 = false;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    getListByGenre();
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
          : ListView(
              children: [
                Container(
                  height: MediaQuery.of(context).size.width * 0.6,
                  child: SHome(
                    Movie: true,
                  ),
                ),
                Column(
                  children: [
                    _buildRowView(data2['Movies'][0], 'Action'),
                    _buildRowView(data2['Movies'][1], 'Adventure'),
                    _buildRowView(data2['Movies'][2], 'Animation'),
                    _buildRowView(data2['Movies'][3], 'Biography'),
                    _buildRowView(data2['Movies'][4], 'Sci-Fi'),
                  ],
                )
              ],
            ),
    );
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
                      // if (value == '1') {
                      //   Navigator.push(
                      //       context,
                      //       MaterialPageRoute(
                      //           builder: (context) => GenreMore(
                      //                 data: data,
                      //                 name: name,
                      //               )));
                      // }
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
                                  builder: (context) => MovieDetail(
                                        title: data['titles'][index],
                                        img: data['img'][index],
                                        desc: data['desp'][index],
                                        file: data['URL'][index],
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
                                  errorWidget: (context, url, error) {
                                    return Image.asset('assets/logo.jpg');
                                  },
                                  placeholder: (context, url) {
                                    return Image.asset('assets/logo.jpg');
                                  },
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

    _popup() {
      return PopupMenuButton(
          icon: Icon(Icons.more_vert),
          itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                const PopupMenuItem(
                  child: ListTile(
                    leading: Icon(Icons.add),
                    title: Text('Item 1'),
                  ),
                ),
              ]);
    }
  }
}
