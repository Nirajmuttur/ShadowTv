import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class SHome extends StatefulWidget {
  bool Movie;
  SHome({this.Movie});
  @override
  _SHomeState createState() => _SHomeState();
}

class _SHomeState extends State<SHome> {
  final PageController pageController = new PageController(initialPage: 0);
  List<String> url = [
    "https://images-na.ssl-images-amazon.com/images/I/81DPd3NRq0L._RI_.jpg",
    "https://i.ytimg.com/vi/IgVyroQjZbE/maxresdefault.jpg",
    "https://images-na.ssl-images-amazon.com/images/I/817BHQcbuwL._RI_.jpg",
    "https://images-na.ssl-images-amazon.com/images/I/81ct8lOcWeL._AC_SL1500_.jpg",
    "https://akm-img-a-in.tosshub.com/indiatoday/images/story/202001/Breaking_Bad.jpeg",
    "https://img1.hotstarext.com/image/upload/f_auto/sources/r1/cms/prod/4909/474909-h.jpeg"
  ];
  List<String> mURL = [
    "https://www.cnet.com/a/img/8hCTVdv5PbjQe3QwbS17Sw9CTPo=/1200x675/2019/04/25/9277c764-601d-4ab3-85f9-9c39d7f1ac5a/avengers-endgame-promo-crop.jpg",
    "https://image.slidesharecdn.com/presentation-avatarfilmposteranalysis-150303060114-conversion-gate01/95/avatar-film-poster-analysis-1-638.jpg",
    "https://hips.hearstapps.com/digitalspyuk.cdnds.net/13/40/movies-dhoom-3-official-poster.jpg",
    "https://cdn.dnaindia.com/sites/default/files/styles/full/public/2018/10/09/741503-chichore-poster.jpg",
    "https://i.pinimg.com/originals/38/87/6c/38876c232bc92c03290065915c1b3854.jpg"
  ];
  int _currentPage = 0;

  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 5), (Timer timer) {
      if (_currentPage < (widget.Movie ? mURL.length : url.length)) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      pageController.animateToPage(_currentPage,
          duration: Duration(milliseconds: 300), curve: Curves.easeIn);
    });
  }

  @override
  dispose() {
    pageController.dispose();
    super.dispose();
  }

  _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
        itemCount: widget.Movie ? mURL.length : url.length,
        controller: pageController,
        itemBuilder: (context, index) {
          return Container(
            child: GestureDetector(
              child: Stack(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: CachedNetworkImage(
                        imageUrl:
                            widget.Movie ? "${mURL[index]}" : "${url[index]}",
                        fit: BoxFit.cover),
                  ),
                  Align(
                      alignment: Alignment.bottomLeft,
                      child: Container(
                        height: 120,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black87])),
                      )),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16, 0, 16, 20),
                      child: Stack(
                        children: [
                          Align(
                              alignment: Alignment.bottomLeft,
                              child: Text(
                                'Shadow TV',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontFamily: 'Alaska',
                                    fontSize: 22,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w100),
                              )),
                          Align(
                              alignment: Alignment.bottomRight,
                              child: RichText(
                                  text: TextSpan(
                                text: '${_currentPage + 1}',
                                style: TextStyle(
                                    color: Color(0xffee5c32), fontSize: 12),
                                children: <TextSpan>[
                                  TextSpan(
                                      text: widget.Movie
                                          ? '/${mURL.length}'
                                          : '/${url.length}',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 12))
                                ],
                              )))
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        onPageChanged: _onPageChanged);
  }
}
