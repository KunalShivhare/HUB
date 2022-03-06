import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../strings.dart';
import 'model.dart';

class ProviderData {
  String id;
  List<StringData> name;
  String phone;
  String www;
  String instagram;
  String telegram;
  List<StringData> desc;
  List<StringData> descTitle;
  String address;
  //String avatar;
  bool visible;
  int unread = 0;
  int all = 0;
  String login;
  String lastMessage = "";
  DateTime lastMessageTime = DateTime.now();
  String chatId = "";

  String imageUpperServerPath = "";
  String imageUpperLocalFile = "";
  String logoServerPath = "";
  String logoLocalFile = "";
  List<ImageData> gallery = [];
  //
  List<WorkTimeData> workTime = [];
  List<String> category = [];
  //
  bool select = false;
  final dataKey = new GlobalKey();
  List<LatLng> route;
  double distanceToUser = 0;

  ProviderData({this.id = "", this.name = const [], this.visible = true, this.address = "", this.desc = const [],
    this.phone = "", this.www = "", this.instagram = "", this.telegram = "", this.descTitle = const [],
    this.imageUpperServerPath = "", this.imageUpperLocalFile = "",
    this.logoServerPath = "", this.logoLocalFile = "", this.gallery = const [], this.workTime = const [],
    this.category = const [], //this.avatar = ""
    this.login = "", required this.route,
  });

  factory ProviderData.createEmpty(){
    return ProviderData(descTitle: [StringData(code: "en", text: strings.get(73))], route: []); // "Description",
  }

  Map<String, dynamic> toJson() => {
    'name': name.map((i) => i.toJson()).toList(),
    'phone': phone,
    'www': www,
    'instagram': instagram,
    'telegram': telegram,
    'desc': desc.map((i) => i.toJson()).toList(),
    'descTitle': descTitle.map((i) => i.toJson()).toList(),
    'address': address,
    'visible': visible,
    'imageUpperServerPath': imageUpperServerPath,
    'imageUpperLocalFile': imageUpperLocalFile,
    'logoServerPath': logoServerPath,
    'logoLocalFile': logoLocalFile,
    'gallery': gallery.map((i) => i.toJson()).toList(),
    'workTime': workTime.map((i) => i.toJson()).toList(),
    'category': category,
    "login" : login,
    "route" : route.map((i){
      return {'lat': i.latitude, 'lng': i.longitude};
    }).toList(),
  };

  factory ProviderData.fromJson(String id, Map<String, dynamic> data){
    List<String> _category = [];
    if (data['category'] != null)
      List.from(data['category']).forEach((element){
        _category.add(element);
      });
    List<ImageData> _gallery = [];
    if (data['gallery'] != null)
      List.from(data['gallery']).forEach((element){
        _gallery.add(ImageData(serverPath: element["serverPath"], localFile: element["localFile"]));
      });
    //
    List<WorkTimeData> _workTime = [];
    if (data['workTime'] != null)
      List.from(data['workTime']).forEach((element){
        _workTime.add(WorkTimeData.fromJson(element));
      });
    //
    List<StringData> _name = [];
    if (data['name'] != null)
      List.from(data['name']).forEach((element){
        _name.add(StringData.fromJson(element));
      });
    List<StringData> _desc = [];
    if (data['desc'] != null)
      List.from(data['desc']).forEach((element){
        _desc.add(StringData.fromJson(element));
      });
    List<StringData> _descTitle = [];
    if (data['descTitle'] != null)
      List.from(data['descTitle']).forEach((element){
        _descTitle.add(StringData.fromJson(element));
      });
    List<LatLng> _route = [];
    if (data["route"] != null)
      List.from(data['route']).forEach((element){
        if (element['lat'] != null && element['lng'] != null)
          _route.add(LatLng(
              element['lat'], element['lng']
          ));
      });
    return ProviderData(
      id: id,
      name: _name,
      phone: (data["phone"] != null) ? data["phone"] : "",
      www: (data["www"] != null) ? data["www"] : "",
      instagram: (data["instagram"] != null) ? data["instagram"] : "",
      telegram: (data["telegram"] != null) ? data["telegram"] : "",
      desc: _desc,
      descTitle: _descTitle,
      address: (data["address"] != null) ? data["address"] : "",
      visible: (data["visible"] != null) ? data["visible"] : true,
      imageUpperServerPath: (data["imageUpperServerPath"] != null) ? data["imageUpperServerPath"] : "",
      imageUpperLocalFile: (data["imageUpperLocalFile"] != null) ? data["imageUpperLocalFile"] : "",
      logoServerPath: (data["logoServerPath"] != null) ? data["logoServerPath"] : "",
      logoLocalFile: (data["logoLocalFile"] != null) ? data["logoLocalFile"] : "",
      gallery: _gallery,
      workTime: _workTime,
      category: _category,
      //avatar: (data["avatar"] != null) ? data["avatar"] : "",
      login: (data["login"] != null) ? data["login"] : "",
      route : _route,
    );
  }
}


class WorkTimeData{
  int id = 0;
  bool weekend = false;
  String openTime = "";
  String closeTime = "";

  WorkTimeData({this.id = 0, this.openTime = "09:00", this.closeTime = "16:00", this.weekend = false});

  Map<String, dynamic> toJson() => {
    'index': id,
    'openTime': openTime,
    'closeTime': closeTime,
    'weekend': weekend,
  };

  factory WorkTimeData.fromJson(Map<String, dynamic> data){
    return WorkTimeData(
      id: (data["index"] != null) ? data["index"] : 0,
      openTime: (data["openTime"] != null) ? data["openTime"] : "9:00",
      closeTime: (data["closeTime"] != null) ? data["closeTime"] : "16:00",
      weekend: (data["weekend"] != null) ? data["weekend"] : false,
    );
  }

  factory WorkTimeData.createEmpty(){
    return WorkTimeData();
  }
}