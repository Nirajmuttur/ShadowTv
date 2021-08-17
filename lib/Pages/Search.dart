import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:movieapp/Pages/Movie/MovieDetail.dart';
import 'package:movieapp/Pages/SeriesDetail.dart';
import 'package:movieapp/networkUtils/movieAPICalls.dart';
import 'package:movieapp/networkUtils/seriesAPICalls.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  Network networkHandler = new Network();
  MovieNetwork movieNetwork = new MovieNetwork();
  final globalKey = new GlobalKey<ScaffoldState>();
  final TextEditingController _controller = new TextEditingController();
  String _chosenValue;
  bool load = true;
  bool load2 = false;
  bool internet = true;
  var data1;
  var data2;
  var data;

  @override
  void initState() {
    super.initState();
  }

  @override
  dispose() {
    _controller.dispose();
    super.dispose();
  }

  void getSearchResult(String text) async {
    setState(() {
      load2 = true;
    });
    try {
      final response = _chosenValue == 'TvShow'
          ? await networkHandler.getSearchResults("/api/search", text)
          : await movieNetwork
              .getSearchResults("/api/movies/searchbyName?movieName=" + text);
      data2 = json.decode(response.body);
      setState(() {
        load = false;
        load2 = false;
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
        title: Text("Search"),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: _controller,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search text here...",
                hintStyle: TextStyle(color: Colors.white60, letterSpacing: 1),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            DropdownButton<String>(
              value: _chosenValue,
              style: TextStyle(color: Colors.white),
              items: <String>['TvShow', 'Movies']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              dropdownColor: Color(0xff222831),
              hint: Text(
                "Please Choose type",
                style: TextStyle(
                    color: Colors.white60, fontSize: 15, letterSpacing: 1),
              ),
              onChanged: (String value) {
                setState(() {
                  _chosenValue = value;
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                FlatButton(
                  color: Colors.black12,
                  child: Text(
                    "Search",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: _search,
                ),
              ],
            ),
            Expanded(
              child: internet
                  ? load == true
                      ? load2
                          ? Center(
                              child: SpinKitWave(
                              color: Colors.white,
                              size: 20.0,
                            ))
                          : Center(
                              child: Text(
                                'Search TVShow & Movies!',
                                style: TextStyle(color: Colors.white),
                              ),
                            )
                      : data2.length == 0
                          ? Center(
                              child: Text("No results found.",
                                  style: TextStyle(color: Colors.white)),
                            )
                          : GridView.builder(
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                mainAxisExtent: 200,
                                crossAxisCount: 3,
                                crossAxisSpacing: 4.0,
                                mainAxisSpacing: 4.0,
                              ),
                              itemCount: data2['Titles'].length,
                              itemBuilder: (BuildContext ctx, int index) {
                                return GestureDetector(
                                  onTap: () {
                                    _chosenValue == 'TvShow'
                                        ? Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    SeriesDetail(
                                                      title: data2['Titles']
                                                          [index],
                                                      imgsrc: data2['Images']
                                                          [index],
                                                      desc:
                                                          data2['Description'],
                                                    )))
                                        : Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    MovieDetail(
                                                      title: data2['Titles']
                                                          [index],
                                                      img: data2['Images']
                                                          [index],
                                                      desc: data2['Description']
                                                          [index],
                                                      file: data2['URL'][index],
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
                                              return Image.asset(
                                                  'assets/logo.jpg');
                                            },
                                            placeholder: (context, url) {
                                              return Image.asset(
                                                  'assets/logo.jpg');
                                            },
                                            imageUrl: _chosenValue == 'TvShow'
                                                ? "http://url/${data2['Images'][index]}"
                                                : "http://url/${data2['Images'][index]}",
                                            fit: BoxFit.cover,
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Text(
                                                '${data2['Titles'][index]}',
                                                style: TextStyle(
                                                    color: Colors.white),
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
                              },
                            )
                  : Center(
                      child: Text(
                        'Please Check Your Internet Connection!',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  _search() async {
    getSearchResult(_controller.text);
  }
}
