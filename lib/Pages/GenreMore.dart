import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:movieapp/Pages/SeriesDetail.dart';

class GenreMore extends StatefulWidget {
  var data;
  String name;
  GenreMore({this.data, this.name});
  @override
  _GenreMoreState createState() => _GenreMoreState();
}

class _GenreMoreState extends State<GenreMore> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff00adb5),
        title: Text('${widget.name}'),
      ),
      backgroundColor: Color(0xff222831),
      body: GridView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            mainAxisExtent: 200,
            crossAxisCount: 3,
            crossAxisSpacing: 4.0,
            mainAxisSpacing: 4.0,
          ),
          itemCount: widget.data['titles'].length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SeriesDetail(
                              title: widget.data['titles'][index],
                              desc: widget.data['desp'][index],
                              imgsrc: widget.data['img'][index],
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
                        imageUrl: "http://url/${widget.data['img'][index]}",
                        fit: BoxFit.cover,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }
}
