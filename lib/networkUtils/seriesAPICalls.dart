import 'dart:async';
import 'dart:convert';
import 'package:localstorage/localstorage.dart';
import 'package:movieapp/constants/constants.dart';
import 'package:http/http.dart' as http;

class Network {
  String url1 = "/api/updateSeries";
  String url2 = "/api/listByGenre";

  String formatUrl(String url) {
    return Constant.base_url + url;
  }

  static LocalStorage storage = new LocalStorage('LatestSeries');
  static LocalStorage storage2 = new LocalStorage('SeriesByGenre');
  static LocalStorage storage3 = new LocalStorage('RecentlyViewed');

  Future getLatestSeries() async {
    var latestSeries = await getLatestSeriesFromCache();
    if (latestSeries == null) {
      return getLatestSeriesFromAPI(url1);
    }
    return latestSeries;
  }

  Future getLatestSeriesFromAPI(String url) async {
    url = formatUrl(url);
    var res = await http.get(Uri.parse(url));
    var _data = json.decode(res.body);
    saveLatestSeries(_data);
    return _data;
  }

  void saveLatestSeries(var data) async {
    await storage.ready;
    storage.setItem('LatestSeries', data);
  }

  Future getLatestSeriesFromCache() async {
    await storage.ready;
    var data = storage.getItem('LatestSeries');
    if (data == null) {
      return null;
    }
    return data;
  }

  Future getSeriesByGenre() async {
    var seriesByGenre = await getSeriesByGenreFromCache();
    if (seriesByGenre == null) {
      return getSeriesByGenreFromAPI(url2);
    }
    return seriesByGenre;
  }

  Future getSeriesByGenreFromAPI(String url) async {
    url = formatUrl(url);
    var res = await http.get(Uri.parse(url));
    var _data = json.decode(res.body);
    saveSeriesByGenre(_data);
    return _data;
  }

  void saveSeriesByGenre(var data) async {
    await storage2.ready;
    storage2.setItem('SeriesByGenre', data);
  }

  Future getSeriesByGenreFromCache() async {
    await storage2.ready;
    var data = storage2.getItem('SeriesByGenre');
    if (data == null) {
      return null;
    }
    return data;
  }

  Future<http.Response> getSeriesDetail(String url) async {
    url = formatUrl(url);
    var res = await http.get(Uri.parse(url));
    //var _data1 = jsonDecode(res.body);
    //saveRecentlyViewed(_data1);
    return res;
  }

  Future getRecentlyViewedFromCache() async {
    await storage3.ready;
    var data = storage3.getItem('RecentlyViewed');
    return data;
  }

  // void saveRecentlyViewed(var data) async {
  //   await storage3.ready;
  //   storage3.setItem('RecentlyViewed', data);
  // }

  Future<http.Response> getEpisodeDetail(String url, String file) async {
    url = formatUrl(url);
    var res = await http.get(Uri.parse(url), headers: {"file": file});
    return res;
  }

  Future<http.Response> getSearchResults(String url, String page) async {
    url = formatUrl(url);
    var res = await http.get(Uri.parse(url), headers: {"page": page});
    return res;
  }
}
