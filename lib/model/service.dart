import 'package:flutter/material.dart';
import '../util.dart';
import 'model.dart';

class ServiceData {
  String id;
  List<StringData> name;
  List<StringData> descTitle;
  List<StringData> desc;
  double tax;
  double taxAdmin;
  bool visible;
  List<PriceData> price;
  List<ImageData> gallery;
  Duration duration = Duration();
  List<String> category;
  List<String> providers; // Id
  //
  bool select = false;
  final dataKey = new GlobalKey();
  //
  int rating1;
  int rating2;
  int rating3;
  int rating4;
  int rating5;
  int count = 0;
  double rating = 0;
  //
  List<AddonData> addon;

  ServiceData(this.id, this.name, {this.visible = true, required this.desc,
    required this.gallery, required this.descTitle, required this.price,
    required this.duration, required this.category, required this.providers, this.tax = 0,
    this.rating1 = 0, this.rating2 = 0, this.rating3 = 0, this.rating4 = 0, this.rating5 = 0,
    this.count = 0, this.rating = 0, this.taxAdmin = 0, required this.addon
  });

  factory ServiceData.createEmpty(){
    return ServiceData("", [], gallery: [], price: [], desc: [], descTitle: [],
        duration: Duration(), category: [], providers: [], addon: []);
  }

  Map<String, dynamic> toJson() => {
    'name': name.map((i) => i.toJson()).toList(),
    'tax': tax,
    'descTitle': descTitle.map((i) => i.toJson()).toList(),
    'desc': desc.map((i) => i.toJson()).toList(),
    'visible': visible,
    'price': price.map((i) => i.toJson()).toList(),
    'gallery': gallery.map((i) => i.toJson()).toList(),
    'duration': duration.inMilliseconds,
    'category' : category,
    'providers': providers,
    'rating1': rating1,
    'rating2': rating2,
    'rating3': rating3,
    'rating4': rating4,
    'rating5': rating5,
    'taxAdmin': taxAdmin,
    'addon': addon.map((i) => i.toJson()).toList(),
  };

  factory ServiceData.fromJson(String id, Map<String, dynamic> data){
    List<StringData> _name = [];
    if (data['name'] != null)
      List.from(data['name']).forEach((element){
        _name.add(StringData.fromJson(element));
      });
    List<StringData> _descTitle = [];
    if (data['descTitle'] != null)
      List.from(data['descTitle']).forEach((element){
        _descTitle.add(StringData.fromJson(element));
      });
    List<StringData> _desc = [];
    if (data['desc'] != null)
      List.from(data['desc']).forEach((element){
        _desc.add(StringData.fromJson(element));
      });
    List<PriceData> _price = [];
    if (data['price'] != null)
      List.from(data['price']).forEach((element){
        _price.add(PriceData.fromJson(element));
      });
    List<ImageData> _gallery = [];
    if (data['gallery'] != null)
      List.from(data['gallery']).forEach((element){
        _gallery.add(ImageData.fromJson(element));
      });
    List<String> _category = [];
    if (data['category'] != null)
      List.from(data['category']).forEach((element){
        _category.add(element);
      });
    List<String> _providers = [];
    if (data['providers'] != null)
      List.from(data['providers']).forEach((element){
        _providers.add(element);
      });
    var rating1 = (data["rating1"] != null) ? toInt(data["rating1"].toString()) : 0;
    var rating2 = (data["rating2"] != null) ? toInt(data["rating2"].toString()) : 0;
    var rating3 = (data["rating3"] != null) ? toInt(data["rating3"].toString()) : 0;
    var rating4 = (data["rating4"] != null) ? toInt(data["rating4"].toString()) : 0;
    var rating5 = (data["rating5"] != null) ? toInt(data["rating5"].toString()) : 0;
    var _count = rating1+rating2+rating3+rating4+rating5;
    double _rating = 0;
    if (_count != 0)
      _rating = (rating1*1 + rating2*2 + rating3*3 + rating4*4 + rating5*5)/_count;
    //
    List<AddonData> _addon = [];
    if (data['addon'] != null)
      List.from(data['addon']).forEach((element){
        _addon.add(AddonData.fromJson(element));
      });
    return ServiceData(
      id,
      _name,
      tax: (data["tax"] != null) ? toDouble(data["tax"].toString()) : 0,
      descTitle: _descTitle,
      desc: _desc,
      visible: (data["visible"] != null) ? data["visible"] : true,
      price: _price,
      gallery: _gallery,
      duration: (data["duration"] != null) ? Duration(milliseconds : data["duration"]) : Duration(),
      category: _category,
      providers: _providers,
      rating1: rating1,
      rating2: rating2,
      rating3: rating3,
      rating4: rating4,
      rating5: rating5,
      count: _count,
      rating: _rating,
      taxAdmin: (data["taxAdmin"] != null) ? toDouble(data["taxAdmin"].toString()) : 0,
      addon: _addon,
    );
  }

  //
  //
  //
  double getMinPrice(){
    double _min = double.maxFinite;
    for (var item in price) {
      if (item.discPrice == 0) {
        if (_min > item.price)
          _min = item.price;
      }else {
        if (_min > item.discPrice)
          _min = item.discPrice;
      }
    }
    if (_min == double.maxFinite)
      return _min;
    return _min;
  }
}

class PriceData{
  List<StringData> name;
  double price;
  double discPrice;
  String priceUnit; // "hourly" or "fixed"
  ImageData image;
  bool selected;
  PriceData(this.name, this.price, this.discPrice, this.priceUnit, this.image, {this.selected = false});

  factory PriceData.createEmpty(){
    return PriceData([], 0, 0, "hourly", ImageData());
  }

  Map<String, dynamic> toJson() => {
    'name': name.map((i) => i.toJson()).toList(),
    'price': price,
    'discPrice': discPrice,
    'priceUnit': priceUnit,
    'image': image.toJson(),
  };

  factory PriceData.fromJson(Map<String, dynamic> data){
    List<StringData> _name = [];
    if (data['name'] != null)
      List.from(data['name']).forEach((element){
        _name.add(StringData.fromJson(element));
      });
    var _image = ImageData();
    if (data['image'] != null)
      _image = ImageData.fromJson(data['image']);
    return PriceData(
      _name,
      (data["price"] != null) ? toDouble(data["price"].toString()) : 0,
      (data["discPrice"] != null) ? toDouble(data["discPrice"].toString()) : 0,
      (data["priceUnit"] != null) ? data["priceUnit"] : "",
      _image,
    );
  }

  double getPrice(){
    return discPrice != 0 ? discPrice : price;
  }

  String getPriceString(MainModel _mainModel){
    return _mainModel.localAppSettings.
        getPriceString(getPrice());
  }
}


class AddonData{
  String id;
  List<StringData> name;
  double price;

  int needCount = 1;

  bool selected;
  AddonData(this.id, this.name, this.price, {this.selected = false, this.needCount = 1});

  factory AddonData.createEmpty(){
    return AddonData("", [], 0);
  }

  Map<String, dynamic> toJson() => {
    'id' : id,
    'name': name.map((i) => i.toJson()).toList(),
    'price': price,
    'needCount': needCount,
  };

  factory AddonData.fromJson(Map<String, dynamic> data){
    List<StringData> _name = [];
    if (data['name'] != null)
      List.from(data['name']).forEach((element){
        _name.add(StringData.fromJson(element));
      });
    return AddonData(
      data["id"] != null ? data["id"] : "",
      _name,
      (data["price"] != null) ? toDouble(data["price"].toString()) : 0,
      needCount: data["needCount"] != null ? toInt(data["needCount"].toString()) : 1,
    );
  }
}
