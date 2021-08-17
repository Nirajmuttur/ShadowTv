import 'dart:async';
import 'dart:convert';
import 'package:localstorage/localstorage.dart';
import 'package:movieapp/constants/constants.dart';
import 'package:http/http.dart' as http;

class MovieNetwork {
  String url2 = "/api/movies/listByGenre";
  String formatUrl(String url) {
    return Constant.base_url + url;
  }

  static LocalStorage storage4 = new LocalStorage('MoviesByGenre');

  Future getMoviesByGenre() async {
    var moviesByGenre = await getMoviesByGenreFromCache();
    if (moviesByGenre == null) {
      return getMoviesByGenreFromAPI(url2);
    }
    return moviesByGenre;
  }

  Future getMoviesByGenreFromAPI(String url) async {
    url = formatUrl(url);
    var res = await http.get(Uri.parse(url));
    var _data = json.decode(res.body);
    saveMoviesByGenre(_data);
    return _data;
  }

  void saveMoviesByGenre(var data) async {
    await storage4.ready;
    storage4.setItem('MoviesByGenre', data);
  }

  Future getMoviesByGenreFromCache() async {
    await storage4.ready;
    var data = storage4.getItem('MoviesByGenre');
    if (data == null) {
      return null;
    }
    return data;
  }

  Future<http.Response> getMovieDetail(String url, String file) async {
    url = formatUrl(url);
    var res = await http.get(Uri.parse(url), headers: {"file": file});
    //var _data1 = jsonDecode(res.body);
    //saveRecentlyViewed(_data1);
    return res;
  }

  Future<http.Response> getSearchResults(String url) async {
    url = formatUrl(url);
    var res = await http.get(Uri.parse(url));
    return res;
  }
}
