class Series {
  String title, desc, imgsrc;
  Series({this.desc, this.imgsrc, this.title});

  Map toJson() => {'title': title, 'desc': desc, "imgsrc": imgsrc};
}
