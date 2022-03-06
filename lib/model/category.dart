
import 'package:flutter/material.dart';

import '../util.dart';
import 'model.dart';

class CategoryData {
  String id;
  List<StringData> name;
  List<StringData> desc;
  bool visible;
  bool visibleCategoryDetails;

  String localFile = "";
  String serverPath = "";

  Color color;
  String parent;
  bool select = false;
  final dataKey = new GlobalKey();
  final dataKey2 = new GlobalKey();
  CategoryData({required this.id, required this.name,
    required this.localFile, required this.serverPath,
    required this.color, required this.parent,
    required this.visible, required this.visibleCategoryDetails, required this.desc});

  factory CategoryData.createEmpty(){
    return CategoryData(id: "", name: [], localFile: "", serverPath: "",
        color: Colors.green, parent: "", visible: true, visibleCategoryDetails: true, desc: []);
  }

  Map<String, dynamic> toJson() => {
    'name' : name.map((i) => i.toJson()).toList(),
    'desc' : desc.map((i) => i.toJson()).toList(),
    'visible' : visible,
    'visibleCategoryDetails' : visibleCategoryDetails,
    'localFile': localFile,
    'serverPath' : serverPath,
    'color': color.value.toString(),
    'parent' : parent
  };

  factory CategoryData.fromJson(String id, Map<String, dynamic> data){
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
    return CategoryData(
      id: id,
      name: _name,
      localFile: (data["localFile"] != null) ? data["localFile"] : "",
      serverPath: (data["serverPath"] != null) ? data["serverPath"] : "",
      color: (data["color"] != null) ? toColor(data["color"]) : Colors.red,
      parent: (data["parent"] != null) ? data["parent"] : "",
      visible: (data["visible"] != null) ? data["visible"] : true,
      visibleCategoryDetails: (data["visibleCategoryDetails"] != null) ? data["visibleCategoryDetails"] : true,
      desc: _desc,
    );
  }

}