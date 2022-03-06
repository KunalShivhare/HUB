import 'package:cloud_firestore/cloud_firestore.dart';

import '../util.dart';
import 'model.dart';

List<BlogData> blog = [];

int _limit = 4;
QueryDocumentSnapshot<Map<String, dynamic>>? _lastDocument;
bool _working = false;

Future<String?> loadBlog(bool _fromStart) async{
  if (_working)
    return null;
  _working = true;
  if (_fromStart)
    _lastDocument = null;
  try{
    late var querySnapshot;
    if (_lastDocument == null){
      blog = [];
      querySnapshot = await FirebaseFirestore.instance.collection("blog").orderBy('time', descending: true)
          .limit(_limit).get();
    }else
      querySnapshot = await FirebaseFirestore.instance.collection("blog").orderBy('time', descending: true)
          .startAfterDocument(_lastDocument!).limit(_limit).get();

    querySnapshot.docs.forEach((result) {
      var _data = result.data();
      var t = BlogData.fromJson(result.id, _data);
      blog.add(t);
    });
    _lastDocument = querySnapshot.docs[querySnapshot.docs.length - 1];
    print("_lastDocument.id = ${_lastDocument!.id}");
  }catch(ex){
    _working = false;
    return "loadBlog " + ex.toString();
  }
  _working = false;
  return null;
}


class BlogData {
  String id;
  List<StringData> name;
  List<StringData> desc;
  List<StringData> text;
  List<StringData> textCompress = [];
  DateTime time;
  String localFile;
  String serverPath;

  BlogData({required this.id, required this.name, required this.text,
    required this.time, required this.desc, this.localFile = "", this.serverPath = ""});

  factory BlogData.createEmpty(){
    return BlogData(id: "", name: [], text: [], time: DateTime.now(), desc: []
    );
  }

  Map<String, dynamic> toJson() {
    textCompress = [];
    for (var item in text)
      textCompress.add(StringData(code: item.code, text: compress(item.text)));
    return {
      'name': name.map((i) => i.toJson()).toList(),
      'textCompress': textCompress.map((i) => i.toJson()).toList(),
      'time': id.isEmpty ? FieldValue.serverTimestamp() : time,
      'localFile': localFile,
      'serverPath' : serverPath,
      'desc' : desc.map((i) => i.toJson()).toList(),
    };
  }

  factory BlogData.fromJson(String id, Map<String, dynamic> data){
    List<StringData> _name = [];
    if (data['name'] != null)
      List.from(data['name']).forEach((element){
        _name.add(StringData.fromJson(element));
      });
    List<StringData> _text = [];
    if (data['textCompress'] != null) {
      List.from(data['textCompress']).forEach((element){
        _text.add(StringData(
          code: (element["code"] != null) ? element["code"] : "",
          text: (element["text"] != null) ? deCompress(element["text"]) : "",
        ));
      });
    }
    List<StringData> _desc = [];
    if (data['desc'] != null)
      List.from(data['desc']).forEach((element){
        _desc.add(StringData.fromJson(element));
      });
    return BlogData(
      id: id,
      name: _name,
      text: _text,
      time: (data["time"] != null) ? data["time"].toDate().toLocal() : DateTime.now(),
      desc: _desc,
      localFile: (data["localFile"] != null) ? data["localFile"] : "",
      serverPath: (data["serverPath"] != null) ? data["serverPath"] : "",
    );
  }
}
