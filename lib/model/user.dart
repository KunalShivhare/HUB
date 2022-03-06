import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../util.dart';


class UserData {
  final String id;
  String name;
  final String email;
  final String role;
  String logoServerPath;
  final bool providerApp;
  String fcb;
  bool subscription; //subscription change
  String subscriptiontype;

  int unread = 0;
  int all = 0;
  String lastMessage = "";
  DateTime? lastMessageTime;
  List<AddressData> address;

  // ignore: cancel_subscriptions
  StreamSubscription<DocumentSnapshot>? listen;

  UserData({this.subscriptiontype="",this.id = "", this.name = "", this.role  = "",
    this.logoServerPath = "", this.providerApp = false, this.email = "", this.fcb = "", required this.address,required this.subscription}); //subscription change

  Map<String, dynamic> toJson() => {
    'name': name,
    'role': role,
    'email': email,
    'logoServerPath': logoServerPath,
    'providerApp': providerApp,
    'FCB': fcb,
    'subscription':subscription,  //subscription change
    'subscriptiontype':subscriptiontype,
    'address': address.map((i) => i.toJson()).toList(),
  };

  factory UserData.fromJson(String id, Map<String, dynamic> data){
    List<AddressData> _address = [];
    if (data['address'] != null)
      List.from(data['address']).forEach((element){
        _address.add(AddressData.fromJson(element));
      });
    return UserData(
      id: id,
      name: (data["name"] != null) ? data["name"] : "",
      email: (data["email"] != null) ? data["email"] : "",
      role: (data["role"] != null) ? data["role"] : "",
      fcb: (data["FCB"] != null) ? data["FCB"] : "",
      logoServerPath: (data["logoServerPath"] != null) ? data["logoServerPath"] : "",
      providerApp: (data["providerApp"] != null) ? data["providerApp"] : false,
      address: _address,
      subscription:(data["subscription"]!=null)?data["subscription"]:false, //subscription change
      subscriptiontype: (data["subscriptiontype"]!=null)?data["subscriptiontype"]:"",
    );
  }

  int compareToAll(UserData b){
    return b.all.compareTo(all);
  }
  int compareToUnread(UserData b){
    return b.unread.compareTo(unread);
  }
}

class AddressData{
  String id;
  String address;
  double lat;
  double lng;
  bool current;
  int type; // 1 home - 2 office - 3 other
  String name;
  String phone;

  AddressData({this.id = "", this.address = "", this.lat = 0,
    this.lng = 0, this.current = false, this.type = 1, this.name = "", this.phone = ""});

  factory AddressData.fromJson(Map<String, dynamic> data){
    return AddressData(
      id: (data["id"] != null) ? data["id"] : "",
      address: (data["address"] != null) ? data["address"] : "",
      lat: (data["lat"] != null) ? toDouble(data["lat"].toString()) : 0,
      lng: (data["lng"] != null) ? toDouble(data["lng"].toString()) : 0,
      current: (data["current"] != null) ? data["current"] : false,
      type: (data["type"] != null) ? data["type"] : 1,
      name: (data["name"] != null) ? data["name"] : "",
      phone: (data["phone"] != null) ? data["phone"] : "",
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'address': address,
    'lat': lat,
    'lng': lng,
    'current': current,
    'type' : type,
    'name' : name,
    'phone' : phone,
  };
}