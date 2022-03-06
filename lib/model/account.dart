import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as pu;
import 'package:ondemandservice/model/provider.dart';
import 'package:ondemandservice/model/user.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert' as convert;
import '../strings.dart';
import '../util.dart';
import 'model.dart';

class MainModelUserAccount{
  final MainModel parent;

  MainModelUserAccount({required this.parent});

  double latitude = 0;
  double longitude = 0;
  String address = "";
  bool _openAddressDialog = false;
  String _codeSent = "";

  //
  // ADDRESS
  //

  initProviderDistances() async {
    if (parent.provider.isEmpty)
      return;
    if (parent.userAddress.isEmpty)
      return;
    var _address = getCurrentAddress();
    if (_address.id.isNotEmpty) {
      for (var item in parent.provider) {
        double _dist = double.infinity;
        for (var latLng in item.route) {
          double d = Geolocator.distanceBetween(_address.lat, _address.lng, latLng.latitude, latLng.longitude);
          if (d < _dist)
            _dist = d;
        }
        if (_dist == double.infinity)
          _dist = 0;
        item.distanceToUser = _dist;
      }
    }
    parent.redraw();
  }

  initAddressEdit(TextEditingController _editControllerAddress, TextEditingController _editControllerName,
      TextEditingController _editControllerPhone){
    if (_openAddressDialog){
      _openAddressDialog = false;
      _editControllerAddress.text = address;
      _editControllerName.text = parent.userName;
      _editControllerPhone.text = parent.userPhone;
    }
  }

  addAddressByCurrentPosition(String add) async {

      address = add;
      //await getAddressFromLatLng(LatLng(latitude, longitude), parent);
      openAddAddressDialog();

  }

  openAddAddressDialog(){
    _openAddressDialog = true;
    parent.openDialog("addAddress");
  }

  Future<Position> _getCurrent() async {
    var _currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation)
        .timeout(Duration(seconds: 10));
    return _currentPosition;
  }

  Future<bool> getCurrentLocation() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied)
        return false;
    }
    Position pos = await _getCurrent();
    latitude = pos.latitude;
    longitude = pos.longitude;
    return true;
  }

  AddressData getCurrentAddress(){
    for (var item in parent.userAddress) {
      if (item.current)
        return item;
    }
    if (parent.userAddress.isNotEmpty)
      return parent.userAddress[0];
    return AddressData();
  }

  setCurrentAddress(String id){
    for (var item in parent.userAddress) {
      item.current = false;
      if (item.id == id)
        item.current = true;
    }
    _saveAddress();
    initProviderDistances();
  }

  Future<String?> _saveAddress() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null)
      return "_saveAddress user == null";

    try {
      FirebaseFirestore.instance.collection("listusers").doc(user.uid).set({
        "address": parent.userAddress.map((i) => i.toJson()).toList(),
      }, SetOptions(merge:true)).then((value2) {});
    }catch(ex){
      return "_saveAddress " + ex.toString();
    }
    return null;
  }

  //
  // type
  // 1 - home
  // 2 - office
  // 3 - other
  //

   Future<String?> saveLocation(int _type, String _address, String _name, String _phone) async {
    if (_address.isEmpty)
      return strings.get(133); /// "Please enter address",
    if (_name.isEmpty)
      return strings.get(153); /// "Please Enter name",
    if (_phone.isEmpty)
      return strings.get(209); /// "Please enter phone",

    for (var item in parent.userAddress)
      item.current = false;

    parent.userAddress.add(AddressData(
        id: Uuid().v4(),
        address: _address,
        lat: latitude,
        lng: longitude,
        current: true,
        type: _type,
        name: _name,
        phone: _phone,
    ));

    var t = await _saveAddress();
    if (t == null){
      latitude = 0;
      longitude = 0;
    }

    initProviderDistances();

    return t;
  }

  Future<String?> deleteLocation(AddressData item) async {
    parent.userAddress.remove(item);
    return _saveAddress();
  }

  bool ifUserAddressInProviderRoute(){
    AddressData _address = getCurrentAddress();
    ProviderData? _provider = parent.getProviderById(parent.currentService.providers[0]);

    if (_provider == null || _address.id.isEmpty)
      return false;
    if (_provider.route.isEmpty)
      return false;

    List<pu.LatLng> _route = [];
    for (var item in _provider.route)
      _route.add(pu.LatLng(item.latitude, item.longitude));

    return pu.PolygonUtil.containsLocation(pu.LatLng(_address.lat, _address.lng), _route, false);
  }

  LatLng getProviderRouteLatLng(){
    ProviderData? _provider = parent.getProviderById(parent.currentService.providers[0]);
    if (_provider == null)
      return LatLng(0, 0);
    if (_provider.route.isEmpty)
      return LatLng(0, 0);

    return _provider.route[0];

  }

  List<LatLng> getProviderRoute(){
    ProviderData? _provider = parent.getProviderById(parent.currentService.providers[0]);
    if (_provider == null)
      return [];
    return _provider.route;
  }


  //
  //
  //


  Future<String?> login(String email, String pass) async {
    try {
      User? user = (await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email, password: pass)).user;

      if (user == null)
        return strings.get(137); /// User not found

      var querySnapshot = await FirebaseFirestore.instance.collection("listusers").doc(user.uid).get();
      if (!querySnapshot.exists)
        return strings.get(137); /// User not found

      var t = querySnapshot.data()!["visible"];
      if (t != null)
        if (!t){
          dprint("User not visible. Don't enter...");
          FirebaseFirestore.instance.collection("listusers").doc(user.uid).set({
            "FCB": "",
          }, SetOptions(merge:true)).then((value2) {});
          await FirebaseAuth.instance.signOut();
          return strings.get(173); /// "User is disabled. Connect to Administrator for more information."
        }
    }catch(ex){
      return "login " + ex.toString();
    }
    dprint("=================login===============");
    return null;
  }

  Future<String?> uploadAvatar(String _imageFile) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null)
      return "uploadAvatar user == null";
    try{
      var f = Uuid().v4();
      var name = "avatar/$f.jpg";
      var firebaseStorageRef = FirebaseStorage.instance.ref().child(name);
      TaskSnapshot s = await firebaseStorageRef.putFile(File(_imageFile));
      parent.userAvatar = await s.ref.getDownloadURL();
      await FirebaseFirestore.instance.collection("listusers").doc(user.uid).set({
        "localFile": name,
        "logoServerPath": parent.userAvatar
      }, SetOptions(merge:true));
    } catch (e) {
      return "uploadAvatar " + e.toString();
    }
    return null;
  }

  bool needOTPParam = false;

  needOTP() async {
    try {
      if (!parent.localAppSettings.isOtpEnable())
        return;

      User? user = FirebaseAuth.instance.currentUser;

      if (user == null)
        return;

      var querySnapshot = await FirebaseFirestore.instance.collection("listusers").doc(user.uid).get();
      if (!querySnapshot.exists)
        return;

      var data = querySnapshot.data();
      if (data == null)
        return;

      bool t = (data["phoneVerified"] == null) ? false : data["phoneVerified"];
      needOTPParam = !t;
      dprint("needOTP t=$t needOTPParam=$needOTPParam");
    }catch(ex){
      dprint("needOTP " + ex.toString());
    }
  }

  String verificationId = "";
  String _lastPhone = "";

  Future<String?> sendOTPCode(String phone, BuildContext context,
      Function(String? s) login, Function() _goToCode) async {
    _lastPhone = checkPhoneNumber("${parent.localAppSettings.otpPrefix}$phone");
    // var _sym = localAppSettings.otpPrefix.length+localAppSettings.otpNumber;
    // if (_lastPhone.length != _sym)
    //   return "${strings.get(141)} $_sym ${strings.get(142)}"; /// "Phone number must be xx symbols",

    try {

    //
    // Twilio
    //
    if (parent.localAppSettings.otpTwilioEnable) {
      var serviceId = parent.localAppSettings.twilioServiceId;
        var url = 'https://verify.twilio.com/v2/Services/$serviceId/Verifications';
        Map<String, String> requestHeaders = {
          'Accept': "application/json",
          'Authorization' : "Basic ${base64Encode(
              utf8.encode("${parent.localAppSettings.twilioAccountSID}:${parent.localAppSettings.twilioAuthToken}"))}",
        };

        var map = new Map<String, dynamic>();
        map['To'] = _lastPhone;
        map['Channel'] = "sms";

        var response = await http.post(Uri.parse(url), headers: requestHeaders,
            body: map).timeout(const Duration(seconds: 30));
        if (response.statusCode == 201) {
          // var jsonResult = json.decode(response.body);
          messageOk(context, strings.get(143)); /// 'Code sent. Please check your phone for the verification code.'
          _goToCode();
          return null; // jsonResult["code_length"];
        }else
          return response.reasonPhrase;
    }

    if (parent.localAppSettings.otpEnable) {
      verificationId = "";
      dprint("sendOTPCode $_lastPhone}");

        await FirebaseAuth.instance.verifyPhoneNumber(
            phoneNumber: _lastPhone,
            timeout: const Duration(seconds: 60),
            verificationCompleted: (PhoneAuthCredential credential) async {
              dprint("Verification complete. number=$_lastPhone code=${credential.smsCode}");
              // User? user = FirebaseAuth.instance.currentUser;
              // if (user != null) {
              //   var user1 = await user.linkWithCredential(credential);
              //   dprint("linkWithCredential =${user1.user!.uid}");
              //   await FirebaseFirestore.instance.collection("listusers").doc(user.uid).set({
              //     "phoneVerified": true,
              //     "phone": _lastPhone,
              //   }, SetOptions(merge:true));
              //   needOTPParam = false;
              //   parent.userPhone = _lastPhone;
              // }

              await FirebaseAuth.instance.signInWithCredential(credential);
              login(credential.smsCode);
            },
            verificationFailed: (FirebaseAuthException e) {
              dprint('Phone number verification failed. Code: ${e.code}. Message: ${e.message}');
              messageError(context, 'Phone number verification failed. Code: ${e.code}. Message: ${e.message}');
            },
            codeSent: (String _verificationId, int? resendToken) {
              verificationId = _verificationId;
              dprint('Code sent. Please check your phone for the verification code. verificationId=$_verificationId');
              messageOk(context, strings.get(143)); /// 'Code sent. Please check your phone for the verification code.'
              _goToCode();
            },
            codeAutoRetrievalTimeout: (String _verificationId) {
              dprint('codeAutoRetrievalTimeout Time Out');
              verificationId = "";
              messageError(context, strings.get(144)); /// 'Time Out'
            }
        );
    }

    //
    // Nexmo
    //
    if (parent.localAppSettings.otpNexmoEnable) {
      _codeSent = generateCode6();
      var _text = parent.localAppSettings.nexmoText.replaceFirst("{code}", _codeSent);
      dprint("otpNexmoEnable $_text}");
      if (_lastPhone.startsWith("+"))
        _lastPhone = _lastPhone.substring(1);
      var response = await http.post(Uri.parse("https://rest.nexmo.com/sms/json"),
          body: convert.jsonEncode({
            "from": "${parent.localAppSettings.nexmoFrom}",
            "text" : "$_text ",
            "to" : "$_lastPhone",
            "api_key": "${parent.localAppSettings.nexmoApiKey}",
            "api_secret": "${parent.localAppSettings.nexmoApiSecret}"
          }),
          headers: {
            "content-type": "application/json",
          });

      final body = convert.jsonDecode(response.body);
      dprint("otpNexmo Send body=$body");
      if (response.statusCode == 200){
        messageOk(context, strings.get(143)); /// 'Code sent. Please check your phone for the verification code.'
        _goToCode();
      }
    }

    //
    // SMS.to
    //
    if (parent.localAppSettings.otpSMSToEnable) {
      _codeSent = generateCode6();
      var _text = parent.localAppSettings.smsToText.replaceFirst("{code}", _codeSent);
      dprint("otpSMSToEnable $_text}");
      var response = await http.post(Uri.parse("https://api.sms.to/sms/send"),
          body: convert.jsonEncode({
            "message": "$_text",
            "to": "$_lastPhone",
            "bypass_optout": false,
            "sender_id": "${parent.localAppSettings.smsToFrom}",
            "callback_url": ""
          }),
          headers: {
            "content-type": "application/json",
            "Authorization": "Bearer ${parent.localAppSettings.smsToApiKey}",
          });

      final body = convert.jsonDecode(response.body);
      dprint("SMSTo Send body=$body");
      if (response.statusCode == 200){
        messageOk(context, strings.get(143)); /// 'Code sent. Please check your phone for the verification code.'
        _goToCode();
      }
    }

    }catch(ex){
      return "sendOTPCode " + ex.toString();
    }

    return null;
  }

  Future<String?> otp(String code) async {
    // if (code.length != 6)
    //   return "";
    try {

    //
    // Twilio
    //
    if (parent.localAppSettings.otpTwilioEnable) {
      var serviceId = parent.localAppSettings.twilioServiceId;

        var url = 'https://verify.twilio.com/v2/Services/$serviceId/VerificationCheck';
        Map<String, String> requestHeaders = {
          'Accept': "application/json",
          'Authorization' : "Basic ${base64Encode(
              utf8.encode("${parent.localAppSettings.twilioAccountSID}:${parent.localAppSettings.twilioAuthToken}"))}",
        };
        var map = new Map<String, dynamic>();
        map['To'] = _lastPhone;
        map['Code'] = code;

        var response = await http.post(Uri.parse(url), headers: requestHeaders, body: map).timeout(const Duration(seconds: 30));
        if (response.statusCode == 200) {
          var jsonResult = json.decode(response.body);
          if (jsonResult['status'] != "approved")
            return strings.get(225); /// Please enter valid code
          User? user = FirebaseAuth.instance.currentUser;
          if (user == null)
            return "user = null";
          await FirebaseFirestore.instance.collection("listusers").doc(user.uid).set({
            "phoneVerified": true,
            "phone": _lastPhone,
          }, SetOptions(merge:true));
          needOTPParam = false;
          parent.userPhone = _lastPhone;
          return null;
        }
        return response.reasonPhrase;
    }

    //
    // Firebase
    //
    if (parent.localAppSettings.otpEnable) {
      //User? user = FirebaseAuth.instance.currentUser;
    //   if(user !=null) {
    //    var querysnapshot= await FirebaseFirestore.instance.collection("listusers").doc(user.uid).get();
    //     var data=querysnapshot.data();
    //     if(data!["phoneVerified"]==true)
    //       return null;
    // }
        PhoneAuthCredential _credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: code);
        FirebaseAuth.instance.signInWithCredential(_credential);
        //_checknewuser();
        // if (user != null) {
        //   var user1 = await user.linkWithCredential(_credential);
        //   dprint("linkWithCredential =${user1.user!.uid}");
        //   await FirebaseFirestore.instance.collection("listusers").doc(user.uid).set({
        //     "phoneVerified": true,
        //     "phone": _lastPhone,
        //   }, SetOptions(merge:true));
        //   needOTPParam = false;
        //   parent.userPhone = _lastPhone;
        // }
    }

    //
    // Nexmo
    //
    if (parent.localAppSettings.otpNexmoEnable) {
      if (_codeSent == code){
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance.collection("listusers").doc(user.uid).set({
            "phoneVerified": true,
            "phone": _lastPhone,
          }, SetOptions(merge:true));
          needOTPParam = false;
          parent.userPhone = _lastPhone;
        }else
          return strings.get(225); /// "Please enter valid code",
      }
    }

    //
    // SMS to
    //
    if (parent.localAppSettings.otpSMSToEnable) {
      if (_codeSent == code){
        User? user = FirebaseAuth.instance.currentUser;
        if(user !=null) {
          var querysnapshot= await FirebaseFirestore.instance.collection("listusers").doc(user.uid).get();
          var data=querysnapshot.data();
          if(data!["phoneVerified"]==true)
            return null;
        }
        if (user != null) {
          await FirebaseFirestore.instance.collection("listusers").doc(user.uid).set({
            "phoneVerified": true,
            "phone": _lastPhone,
          }, SetOptions(merge:true));
          needOTPParam = false;
          parent.userPhone = _lastPhone;
        }
      }else
        return strings.get(225); /// "Please enter valid code",
    }

    }catch(ex){
      return "otp " + ex.toString();
    }
    return null;

  }


}