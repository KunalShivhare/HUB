import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:ondemandservice/ui/theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'model/localSettings.dart';
import 'model/model.dart';
import 'dart:ui' as ui;

dprint(String str){
  if (!kReleaseMode) print(str);
}

Color getColor(String? boardColor){
  if (boardColor == null)
    return Colors.red;
  var t = int.tryParse(boardColor);
  if (t != null)
    return Color(t);
  return Colors.red;
}

messageError(BuildContext context, String _text){
  dprint("messageError $_text");
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.red,
      duration: Duration(seconds: 5),
      content: Text(_text,
        style: TextStyle(color: Colors.white), textAlign: TextAlign.center,)));
}

messageOk(BuildContext context, String _text){
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: mainColor,
      duration: Duration(seconds: 5),
      content: Text(_text,
        style: TextStyle(color: Colors.white), textAlign: TextAlign.center,)));
}


Color toColor(String? boardColor){
  if (boardColor == null)
    return Colors.red;
  var t = int.tryParse(boardColor);
  if (t != null)
    return Color(t);
  return Colors.red;
}

String getTextByLocale(List<StringData> _data){
  for (var item in _data)
    if (item.code == localSettings.locale)
      return item.text;
  for (var item in _data)
    if (item.code == "en")
      return item.text;
  if (_data.isNotEmpty)
    return _data[0].text;
  return "";
}


int toInt(String str){
  int ret = 0;
  try {
    ret = int.parse(str);
  }catch(_){}
  return ret;
}

double toDouble(String str){
  double ret = 0;
  try {
    ret = double.parse(str);
  }catch(_){}
  return ret;
}

bool validateEmail(String value) {
  var pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regex = new RegExp(pattern);
  if (!regex.hasMatch(value))
    return false;
  else
    return true;
}

String checkPhoneNumber(String _phoneText){
  String s = "";
  for (int i = 0; i < _phoneText.length; i++) {
    int c = _phoneText.codeUnitAt(i);
    if ((c == "1".codeUnitAt(0)) || (c == "2".codeUnitAt(0)) || (c == "3".codeUnitAt(0)) ||
        (c == "4".codeUnitAt(0)) || (c == "5".codeUnitAt(0)) || (c == "6".codeUnitAt(0)) ||
        (c == "7".codeUnitAt(0)) || (c == "8".codeUnitAt(0)) || (c == "9".codeUnitAt(0)) ||
        (c == "0".codeUnitAt(0)) || (c == "+".codeUnitAt(0))) {
      String h = String.fromCharCode(c);
      s = "$s$h";
    }
  }
  return s;
}

callMobile(String phone) async {
  var uri = "tel:${checkPhoneNumber(phone)}";
  if (await canLaunch(uri))
    await launch(uri);
}

openUrl(String uri) async {
  if (await canLaunch(uri))
    await launch(uri);
}

String compress(String _data){
  List<int> stringBytes = utf8.encode(_data);
  List<int>? gzipBytes = GZipEncoder().encode(stringBytes);
  String compressedString = base64.encode(gzipBytes!);
  dprint("compressed string: $compressedString");
  dprint("compressed length: ${compressedString.length}");
  return compressedString;
}

String deCompress(String compressedString){
  final decodeBase64Json = base64.decode(compressedString);
  final decodegZipJson = GZipDecoder().decodeBytes(decodeBase64Json);
  final originalJson = utf8.decode(decodegZipJson);
  dprint("originalJson: $originalJson");
  return originalJson;
}

getAddressFromLatLng(LatLng pos, MainModel _mainModel) async {
  GoogleMapsPlaces places = GoogleMapsPlaces(apiKey: _mainModel.localAppSettings.googleMapApiKey);
  PlacesSearchResponse response = await places.searchNearbyWithRadius(new Location(lat: pos.latitude, lng: pos.longitude), 20);
  if (!response.isOkay)
    return response.errorMessage;
  var _textAddress = "";
  if (response.results.isNotEmpty) {
    for (var item in response.results)
      if (item.vicinity != null)
        if (item.vicinity!.length > _textAddress.length)
          _textAddress = item.vicinity!;
  }
  return _textAddress;
}

Future<Uint8List> getBytesFromAsset(String path, int width) async {
  ByteData data = await rootBundle.load(path);
  ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
  ui.FrameInfo fi = await codec.getNextFrame();
  return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
}

String generateCode6(){
  var i1 = Random().nextInt(9);
  var i2 = Random().nextInt(9);
  var i3 = Random().nextInt(9);
  var i4 = Random().nextInt(9);
  var i5 = Random().nextInt(9);
  var i6 = Random().nextInt(9);
  return "$i1$i2$i3$i4$i5$i6";
}