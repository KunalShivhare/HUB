import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ondemandservice/model/provider.dart';
import 'package:ondemandservice/model/service.dart';
import 'package:ondemandservice/model/settings.dart';
import 'package:ondemandservice/model/user.dart';
import 'package:ondemandservice/ui/elements/address.dart';
import 'package:ondemandservice/ui/theme.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:uuid/uuid.dart';
import '../strings.dart';
import 'package:ondemandservice/util.dart';
import 'package:path_provider/path_provider.dart';
import 'account.dart';
import 'banner.dart';
import 'blog.dart';
import 'booking.dart';
import 'category.dart';
import 'filter.dart';
import 'localSettings.dart';
import 'notification.dart';
import 'offers.dart';
import 'package:http/http.dart' as http;

class MainModel with ChangeNotifier, DiagnosticableTreeMixin {

  List<LangData> appLangs = [];
  String directoryPath = "";
  AppSettings localAppSettings = AppSettings.createEmpty();
  List<CategoryData> category = [];
  List<ServiceData> service = [];
  List<ServiceData> serviceSearch = [];
  ServiceData currentService = ServiceData.createEmpty();
  List<ProviderData> provider = [];
  ProviderData currentProvider = ProviderData.createEmpty();
  List<UserData> users = [];
  List<OfferData> offers = [];
  bool searchActivate = false;

  String userEmail = "";
  String userName = "";
  String userPhone = "";
  String userAvatar = "";
  String userSocialLogin = "";
  List<String> userFavorites = [];
  List<AddressData> userAddress = [];
  bool _subscription=false;  //subscription change
  String _subscriptiontype="";
  //
  // Navigation
  //
  BlogData? openBlog;
  AddressData? addressData;
  double windowWidth = 0;
  double windowHeight = 0;
  late Function() redraw;
  late Function(String) route;
  late Function(String) openDialog;

  String getSubtypevalue(){              //subscriptiontype change
    return this._subscriptiontype;
  }

  bool getSubvalue(){              //subscription change
    return this._subscription;
  }

  setMainWindow(double _windowWidth, double _windowHeight,
      Function() _redraw, Function(String) _route, Function(String) _openDialog){
    windowWidth = _windowWidth;
    windowHeight = _windowHeight;
    redraw = _redraw;
    route = _route;
    openDialog = _openDialog;
  }

  List<String> _callbackStack = [];

  String _getCallback(){
    if (_callbackStack.isEmpty)
      return "home";
    _callbackStack.removeLast();
    _debugPrintStack();
    return _callbackStack[_callbackStack.length-1];
  }

  drawState(String _val){
    if (_callbackStack.isEmpty)
       _callbackStack.add(_val);
    else
      if (_callbackStack[_callbackStack.length-1] != _val)
        _callbackStack.add(_val);
    _debugPrintStack();
  }

  callbackStackRemoveLast(){
    if (_callbackStack.isNotEmpty)
      _callbackStack.removeLast();
  }

  _debugPrintStack(){
    var _text = "";
    for (var item in _callbackStack)
      _text = "$_text | $item";
    dprint("_debugPrintStack = $_text");
  }

  goBack(){
    route(_getCallback());
  }

  String currentScreen(){
    if (_callbackStack.isNotEmpty)
      return _callbackStack[_callbackStack.length-1];
    return "";
  }

  //
  //
  //

  ProviderData? getProviderById(String _providerId) {
    for (var item in provider)
      if (item.id == _providerId)
        return item;
  }

  double getDistanceByProviderId(String _providerId){
    var _provider = getProviderById(_providerId);
    if (_provider != null){
      double d = 0;
      if (localAppSettings.distanceUnit == "km")
        d = _provider.distanceToUser/1000;
      else
        d = _provider.distanceToUser/1609.32;
      if (d != 0){
        if (d > 10)
          return d;
        else
          return d;
      }
    }
    return double.infinity;
  }

  String getStringDistanceByProviderId(String _providerId){
    var d = getDistanceByProviderId(_providerId);
    if (d != double.infinity){
      if (d > 10)
        return d.toStringAsFixed(0) + localAppSettings.distanceUnit;
      else
        return d.toStringAsFixed(3) + localAppSettings.distanceUnit;
    }
    return "";
  }


  String getProviderId(String login){
    for (var item in users)
      if (item.email == login)
        return item.id;
    return "";
  }

  String getCategoryNameById(String id){
    for (var item in category)
      if (item.id == id)
        return getTextByLocale(item.name);
    return "";
  }

  String getCategoryNames(List<String> ids){
    var _text = "";
    for (var item in ids) {
      var t = getCategoryNameById(item);
      if (t.isNotEmpty){
        if (_text.isNotEmpty)
          _text = "$_text, ";
        _text = "$_text$t";
      }
    }
    return _text;
  }

  late MainModelBanner banner;
  late MainDataFilter filter;
  late MainModelUserAccount userAccount;

  init(BuildContext context) async {
    banner = MainModelBanner(parent: this);
    filter = MainDataFilter(parent: this);
    userAccount = MainModelUserAccount(parent: this);


    try{
      await _getSettings();
      await _getAppServerSettings();
      await _loadLangsFromLocal(context);
      dprint("--------->");

      //
      //
      // THEME
      //
      //
      if (!themeFromServerLoad)
        await getThemeFromServer();

      //
      //
      // LANGS
      //
      //
      var querySnapshot = await FirebaseFirestore.instance.collection("language").doc("langs").get();
      var data = querySnapshot.data();
      if (data == null)
          return null;
      dprint("loadLanguages data=$data");
      //
      // get version
      //
      if (data['list'] != null) {
        if (data['ver'] == localAppSettings.langVer)
          return null;
        var element = data['list'];
        appLangs = [];
        element.forEach((element) {
          if (element["app"] == "service")
            appLangs.add(LangData(name: element["name"], engName: element["engName"], image: "", app: "service",
                direction: element["direction"] == "ltr" ? TextDirection.ltr : TextDirection.rtl, locale: element["locale"],
                data: {}),);
        });
        // save local
        dprint("appLangs ${appLangs.length} $appLangs");
        await File('$directoryPath/listlangs.json').writeAsString(json.encode(appLangs.map((i) => i.toJson()).toList()));
        localAppSettings.langVer = data['ver'];
        await _saveSettings();
      }
      //
      // get languages
      //
      for (var element in appLangs){
        var _doc = "${element.app}_${element.locale}";
        var querySnapshot = await FirebaseFirestore.instance.collection("language").doc(_doc).get();
        var data = querySnapshot.data();
        if (data != null) {
          Map<String, dynamic> _words = data['data'];
          // save local
          dprint("save language local $_doc");
          var _t = json.encode(_words);
          await File('$directoryPath/$_doc.json').writeAsString(_t);
        }
      }
      _loadLangsFromLocal(context);
    }catch(ex){
      dprint(ex.toString());
      return ex.toString();
    }
    notifyListeners();
  }

  Future<String?> init2() async {
    var ret = await loadCategory();
    if (ret != null)
      return ret;
    ret = await loadService();
    if (ret != null)
      return ret;
    ret = await loadProvider();
    if (ret != null)
      return ret;
    ret = await loadOffers();
    if (ret != null)
      return ret;
    ret = await banner.load();
    if (ret != null)
      return ret;
    notifyListeners();
    return null;
  }

  _loadLangsFromLocal(BuildContext context) async {
    var _file = File('$directoryPath/listlangs.json');
    if (!await _file.exists())
      return;
    final contents = await _file.readAsString();
    var data = json.decode(contents);
    dprint("_loadLangsFromLocal $data");
    appLangs = data.map((f) => LangData.fromJson(f)).cast<LangData>().toList();
    dprint("_loadLangsFromLocal appLangs $appLangs");
    for (var item in appLangs){
      var _doc = "${item.app}_${item.locale}";
      var _file = File('$directoryPath/$_doc.json');
      if (!await _file.exists())
        return;
      final contents = await _file.readAsString();
      dprint('read local lang $directoryPath/$_doc.json');
      item.data = json.decode(contents);
      if (localSettings.locale.isNotEmpty){
        if (localSettings.locale == item.locale)
          strings.setLang(item.data, item.locale, context, item.direction);
      }else
        if (localAppSettings.currentServiceAppLanguage == item.locale)
          strings.setLang(item.data, item.locale, context, item.direction);
    }
  }

  Future<String?> setagentcode(String agcode) async {
    try{                ///Backend Code here
      String uid=FirebaseAuth.instance.currentUser!.uid;

      User? user=FirebaseAuth.instance.currentUser;
      var auid= await FirebaseFirestore.instance.collection("agents").where('Phone',isEqualTo: agcode).get();   //Adding user uid to agent
      await FirebaseFirestore.instance.collection("agents").doc(auid.docs.first.id).set({
        "users":FieldValue.arrayUnion([uid]),
      }, SetOptions(merge: true));

      if(user!=null)                                                                    //Adding agent uid to current user
        await FirebaseFirestore.instance.collection("listusers").doc(user.uid).set({
         "agent referrel":auid.docs.first.id,
        }, SetOptions(merge: true));

    }
    catch(e){
      print(e.toString());
      return "Agent Code:" + e.toString();
    }
    return null;
  }


  _getSettings() async {
    var directory = await getApplicationDocumentsDirectory();
    directoryPath = directory.path;
    var _file = File('$directoryPath/settings.json');
    if (!await _file.exists())
      await _file.writeAsString(json.encode(localAppSettings.toJson()));
    final contents = await _file.readAsString();
    var data = json.decode(contents);
    dprint("_getSettings $data");
    localAppSettings = AppSettings.fromJson(data);
  }

  _saveSettings() async {
    var _file = File('$directoryPath/settings.json');
    var _data = json.encode(localAppSettings.toJson());
    await _file.writeAsString(_data);
  }

  _getAppServerSettings() async {
    try{
      var querySnapshot = await FirebaseFirestore.instance.collection("settings").doc("main").get();
      var data = querySnapshot.data()!;
      localAppSettings.demo = data["demo"] != null ? data["demo"] : false;
      // appname = data["appname"] != null ? data["appname"] : "HANDYMAN";
      localAppSettings.googleMapApiKey = data["google_map_apikey"] != null ? data["google_map_apikey"] : "";
      localAppSettings.cloudKey = data["cloud_key"] != null ? data["cloud_key"] : "";
      localAppSettings.distanceUnit = data["distance_unit"] != null ? data["distance_unit"] : "km";
      localAppSettings.timeFormat = data["time_format"] != null ? data["time_format"] : "24h";
      localAppSettings.dateFormat = data["date_format"] != null ? data["date_format"] : "yyyy.MM.dd";

      localAppSettings.rightSymbol = data["right_symbol"] != null ? data["right_symbol"] : false;
      localAppSettings.digitsAfterComma = data["digits_after_comma"] != null ? data["digits_after_comma"] : 2;
      localAppSettings.code = data["code"] != null ? data["code"] : "USD";
      localAppSettings.symbol = data["symbol"] != null ? data["symbol"] : "\$";
      // documents
      localAppSettings.copyright = data["copyright"] != null ? data["copyright"] : "";
      localAppSettings.about = data["about"] != null ? data["about"] : "";
      localAppSettings.policy = data["policy"] != null ? data["policy"] : "";
      localAppSettings.terms = data["terms"] != null ? data["terms"] : "";
      // payments gateway
      localAppSettings.stripeKey = data["stripe_key"] != null ? data["stripe_key"] : "";
      localAppSettings.stripeSecretKey = data["stripe_secret_key"] != null ? data["stripe_secret_key"] : "";
      localAppSettings.paypalSecretKey = data["paypal_secret_key"] != null ? data["paypal_secret_key"] : "";
      localAppSettings.paypalClientId = data["paypal_client_id"] != null ? data["paypal_client_id"] : "";
      localAppSettings.paypalSandBox = data["paypalSandBox"] != null ? data["paypalSandBox"] : true;
      localAppSettings.razorpayName = data["razorpay_name"] != null ? data["razorpay_name"] : "";
      localAppSettings.razorpayKey = data["razorpay_key"] != null ? data["razorpay_key"] : "";
      localAppSettings.stripeEnable = data["stripe_enable"] != null ? data["stripe_enable"] : false;
      localAppSettings.razorpayEnable = data["razorpay_enable"] != null ? data["razorpay_enable"] : false;
      localAppSettings.paypalEnable = data["paypal_enable"] != null ? data["paypal_enable"] : false;
      // payStack
      localAppSettings.payStackEnable = data["payStack_enable"] != null ? data["payStack_enable"] : false;
      localAppSettings.payStackKey = data["payStackKey"] != null ? data["payStackKey"] : "";
      // FlutterWave
      localAppSettings.flutterWaveEnable = data["flutterWaveEnable"] != null ? data["flutterWaveEnable"] : false;
      localAppSettings.flutterWaveEncryptionKey = data["flutterWaveEncryptionKey"] != null ? data["flutterWaveEncryptionKey"] : "";
      localAppSettings.flutterWavePublicKey = data["flutterWavePublicKey"] != null ? data["flutterWavePublicKey"] : "";
      //
      localAppSettings.googlePlayLink = data["googlePlayLink"] != null ? data["googlePlayLink"] : "";
      localAppSettings.appStoreLink = data["appStoreLink"] != null ? data["appStoreLink"] : "";
      // localAppSettings.darkMode = data["darkMode"] != null ? data["darkMode"] : false;
      //
      localAppSettings.otpEnable = data["otpEnable"] != null ? data["otpEnable"] : false;
      localAppSettings.otpPrefix = data["otpPrefix"] != null ? data["otpPrefix"] : "";
      localAppSettings.otpNumber = data["otpNumber"] != null ? data["otpNumber"] : 10;
      localAppSettings.otpTwilioEnable = data["otpTwilioEnable"] != null ? data["otpTwilioEnable"] : false;
      localAppSettings.twilioAccountSID = data["twilioAccountSID"] != null ? data["twilioAccountSID"] : "";
      localAppSettings.twilioAuthToken = data["twilioAuthToken"] != null ? data["twilioAuthToken"] : "";
      localAppSettings.twilioServiceId = data["twilioServiceId"] != null ? data["twilioServiceId"] : "";
      // nexmo
      localAppSettings.otpNexmoEnable = data["otpNexmoEnable"] != null ? data["otpNexmoEnable"] : false;
      localAppSettings.nexmoFrom = data["nexmoFrom"] != null ? data["nexmoFrom"] : "";
      localAppSettings.nexmoText = data["nexmoText"] != null ? data["nexmoText"] : "";
      localAppSettings.nexmoApiKey = data["nexmoApiKey"] != null ? data["nexmoApiKey"] : "";
      localAppSettings.nexmoApiSecret = data["nexmoApiSecret"] != null ? data["nexmoApiSecret"] : "";
      // sms to
      localAppSettings.otpSMSToEnable = data["otpSMSToEnable"] != null ? data["otpSMSToEnable"] : false;
      localAppSettings.smsToFrom = data["smsToFrom"] != null ? data["smsToFrom"] : "";
      localAppSettings.smsToText = data["smsToText"] != null ? data["smsToText"] : "";
      localAppSettings.smsToApiKey = data["smsToApiKey"] != null ? data["smsToApiKey"] : "";
      //
      localAppSettings.defaultServiceAppLanguage = data["defaultServiceAppLanguage"] != null ? data["defaultServiceAppLanguage"] : "en";
      localAppSettings.defaultProviderAppLanguage = data["defaultProviderAppLanguage"] != null ? data["defaultProviderAppLanguage"] : "en";
      if (localAppSettings.currentServiceAppLanguage.isEmpty)
        localAppSettings.currentServiceAppLanguage = localAppSettings.defaultServiceAppLanguage;
      //
      localAppSettings.statuses = [];
      if (data['statuses'] != null)
        List.from(data['statuses']).forEach((element){
          localAppSettings.statuses..add(StatusData.fromJson(element));
        });
      else
        localAppSettings.statuses = statusesData;
      //
      localAppSettings.inMainScreenServices = [];
      if (data['inMainScreenServices'] != null)
        for (dynamic key in data['inMainScreenServices']){
          localAppSettings.inMainScreenServices.add(key.toString());
        }
      //
      localAppSettings.customerAppElements = [];
      if (data['customerAppElements'] != null)
        for (dynamic key in data['customerAppElements']){
          localAppSettings.customerAppElements.add(key.toString());
        }
      if (!localAppSettings.customerAppElements.contains("search"))
        localAppSettings.customerAppElements.add("search");
      if (!localAppSettings.customerAppElements.contains("banner"))
        localAppSettings.customerAppElements.add("banner");
      if (!localAppSettings.customerAppElements.contains("category"))
        localAppSettings.customerAppElements.add("category");
      if (!localAppSettings.customerAppElements.contains("blog"))
        localAppSettings.customerAppElements.add("blog");
      if (!localAppSettings.customerAppElements.contains("providers"))
        localAppSettings.customerAppElements.add("providers");
      if (!localAppSettings.customerAppElements.contains("category_details"))
        localAppSettings.customerAppElements.add("category_details");
      if (!localAppSettings.customerAppElements.contains("top_service"))
        localAppSettings.customerAppElements.add("top_service");
      if (!localAppSettings.customerAppElements.contains("favorites"))
        localAppSettings.customerAppElements.add("favorites");
      localAppSettings.customerAppElementsDisabled = [];
      if (data['customerAppElementsDisabled'] != null)
        for (dynamic key in data['customerAppElementsDisabled']){
          localAppSettings.customerAppElementsDisabled.add(key.toString());
        }
      for (var item in localAppSettings.customerAppElementsDisabled){
        localAppSettings.customerAppElements.remove(item);
      }

      await _saveSettings();
    }catch(ex){
      return "_getAppServerSettings " + ex.toString();
    }
  }

  setLang(String value, BuildContext context) async {
    localSettings.setLocal(value);
    //
    localAppSettings.currentServiceAppLanguage = value;
    for (var item in appLangs){
      if (localSettings.locale.isNotEmpty){
        if (localSettings.locale == item.locale)
          strings.setLang(item.data, item.locale, context, item.direction);
      }else
        if (localAppSettings.currentServiceAppLanguage == item.locale)
          strings.setLang(item.data, item.locale, context, item.direction);
    }
    await _saveSettings();
  }

  Future<String?> loadCategory() async{
    try{
      var querySnapshot = await FirebaseFirestore.instance.collection("category").get();
      category = [];
      querySnapshot.docs.forEach((result) {
        var _data = result.data();
        var t = CategoryData.fromJson(result.id, _data);
        if(t.visible)
        category.add(t);
      });
    }catch(ex){
      return "loadCategory " + ex.toString();
    }
    return null;
  }

  Future<String?> loadService() async{
    try{
      var querySnapshot = await FirebaseFirestore.instance.collection("service").get();
      service = [];
      querySnapshot.docs.forEach((result) {
        var _data = result.data();
        // dprint("Service $_data");
        var t = ServiceData.fromJson(result.id, _data);
        service.add(t);
      });
    }catch(ex){
      return "loadService " + ex.toString();
    }
    return null;
  }

  Future<String?> loadProvider() async{
    try{
      var querySnapshot = await FirebaseFirestore.instance.collection("provider").get();
      provider = [];
      querySnapshot.docs.forEach((result) {
        var _data = result.data();
        print("Provider $_data");
        var t = ProviderData.fromJson(result.id, _data);
        provider.add(t);
      });
      userAccount.initProviderDistances();
    }catch(ex){
      return "loadProvider " + ex.toString();
    }
    return null;
  }

  //
  // Service
  //
  ImageData getTitleImage(){
    if (currentService.gallery.isNotEmpty)
      return currentService.gallery[0];
    return ImageData();
  }

  PriceData getPrice(){
    PriceData currentPrice = PriceData.createEmpty();
    double _price = double.maxFinite;
    for (var item in currentService.price) {
      if (item.discPrice != 0){
        if (item.discPrice < _price) {
          _price = item.discPrice;
          currentPrice = item;
        }
      }else
      if (item.price < _price) {
        _price = item.price;
        currentPrice = item;
      }
    }
    if (_price == double.maxFinite)
      _price = 0;
    return currentPrice;
  }

  String getProviderAddress(String id){
    String _address = "";
    for (var item in provider)
      if (item.id == id) {
        _address = item.address;
        break;
      }
    return _address;
  }

  List<String> getServiceCategories(List<String> val){
    List<String> ret = [];
    for (var item in val) {
      for (var item2 in category)
        if (item == item2.id) {
          ret.add(getTextByLocale(item2.name));
          break;
        }
    }
    return ret;
  }



  logout() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null)
      FirebaseFirestore.instance.collection("listusers").doc(user.uid).set({
        "FCB": "",
      }, SetOptions(merge:true)).then((value2) {});
    await FirebaseAuth.instance.signOut();
    dprint("=================logout===============");

    userAddress=[];
    userEmail = "";
    userName = "";
    userPhone = "";
    userAvatar = "";
    userSocialLogin = "";
    userFavorites = [];
    _subscription=false;  //subscription change
  }

  changeFavorites(ServiceData item){
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null)
      return;
    try{
      if (userFavorites.contains(item.id)) {
        userFavorites.remove(item.id);
        FirebaseFirestore.instance.collection("service").doc(item.id).set({
          "favoritesCount": FieldValue.increment(-1),
        }, SetOptions(merge:true));
      }else {
        userFavorites.add(item.id);
        FirebaseFirestore.instance.collection("service").doc(item.id).set({
          "favoritesCount": FieldValue.increment(1),
        }, SetOptions(merge:true));
      }

      FirebaseFirestore.instance.collection("listusers").doc(user.uid).set({
        "userFavorites": userFavorites,
      }, SetOptions(merge:true)).then((value2) {});

    }catch(ex){
      return "changeFavorites " + ex.toString();
    }
    return;
  }

  Future<String?> register(String name) async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;

      if (user == null)
        return strings.get(138); /// User don't create

      FirebaseFirestore.instance.collection("listusers").doc(user.uid).set({
        "visible": true,
        "phoneVerified": true,
        "email": user.email,
        "phone": user.phoneNumber,
        "name": name,
        "date_create" : FieldValue.serverTimestamp(),
        "subscription":false  //subscription change
      });

      await FirebaseFirestore.instance.collection("settings").doc("main")
          .set({"customersCount": FieldValue.increment(1)}, SetOptions(merge:true));


      // final User? user = (await FirebaseAuth.instance.createUserWithEmailAndPassword(
      //   email: email, password: pass,)).user;
      //
      // if (user == null)
      //   return strings.get(138); /// User don't create
      //
      // FirebaseFirestore.instance.collection("listusers").doc(user.uid).set({
      //   "visible": true,
      //   "phoneVerified": false,
      //   "email": user.email,
      //   "phone": "",
      //   "name": name,
      //   "date_create" : FieldValue.serverTimestamp(),
      //   "subscription":false  //subscription change
      // });
      //
      // await FirebaseFirestore.instance.collection("settings").doc("main")
      //     .set({"customersCount": FieldValue.increment(1)}, SetOptions(merge:true));

    }catch(ex){
      return "register " + ex.toString();
    }
    return null;
  }

  int chatCount = 0;
  int numberOfUnreadMessages = 0;
  Function()? updateNotify;
  String currentPage = "home";
  bool _alwaysLogin = false;
  bool newuser=false;

  Future checknewuser() async {
    try {
      User? user=FirebaseAuth.instance.currentUser;
      var querysnapshot=await FirebaseFirestore.instance.collection("listusers").doc(user!.uid).get();
      var data=querysnapshot.data();
      if(data!=null){
        if (data['name'] == null)
          newuser = true;
        else
          newuser = false;
      }

      print("New User Check"+ newuser.toString());
    }catch(ex){
      return "New User Check" + ex.toString();
    }
  }

  Future updateuserdetails() async{
   User? user=FirebaseAuth.instance.currentUser;
    print("Registerd User data updated");
    await FirebaseFirestore.instance.collection("listusers").doc(user!.uid).get().then((querySnapshot) async {
      if (querySnapshot.exists){
        var data = querySnapshot.data()!;
        userName = (data["name"]  != null) ? data["name"] : "";
        userPhone = (data["phone"]  != null) ? data["phone"] : "";
        userAvatar = (data["logoServerPath"]  != null) ? data["logoServerPath"] : "";
        userSocialLogin = (data["socialLogin"]  != null) ? data["socialLogin"] : "";
        _subscription=(data["subscription"]!=null)? data["subscription"]:false; //subscription change
        if(userAddress.length<2)
        if (data["address"] != null)
          List.from(data['address']).forEach((element){
            userAddress.add(AddressData.fromJson(element));
          });
        // favorites
        if (data['userFavorites'] != null)
          for (dynamic key in data['userFavorites']){
            userFavorites.add(key.toString());
          }
        //_redraw();
        //userAccount.initProviderDistances();
        //comboBoxInitAddress(this);
      }
    });
  }


  userAndNotifyListen(Function() _redraw, BuildContext context){
    setNotifyCallback((RemoteMessage message){
      dprint("message.notification=${message.notification!.title}");
      if (message.notification != null) {
        dprint("setNotifyCallback ${message.notification!.title}");
        numberOfUnreadMessages++;
        notifyListeners();
        if (currentPage == "notify"){
          if (updateNotify != null) {
            numberOfUnreadMessages = 0;
            updateNotify!();
          }
        }
        dprint("_numberOfUnreadMessages=$numberOfUnreadMessages");
        _redraw();
      }
    });

    setChatCallback((){
        // chatCount++;
        _redraw();
    });


    FirebaseAuth.instance
        .userChanges()
        .listen((User? user) async {

      if (user == null) {
        dprint("=================listen user log out===============");
        if (_listenBooking != null)
          _listenBooking!.cancel();
        _alwaysLogin = false;
      } else {
        if (_alwaysLogin)
          return;
        _alwaysLogin = true;
        await userAccount.needOTP();
        var ret = await listenBooking(_redraw);
        if (ret != null)
          messageError(context, ret);
        dprint("=================listen user login===============");
        FirebaseFirestore.instance.collection("listusers").doc(user.uid).get().then((querySnapshot) async {
          if (querySnapshot.exists){
            var t = querySnapshot.data()!["visible"];
            if (t != null)
              if (!t){
                dprint("User not visible. Exit...");
                FirebaseFirestore.instance.collection("listusers").doc(user.uid).set({
                  "FCB": "",
                }, SetOptions(merge:true)).then((value2) {});
                await FirebaseAuth.instance.signOut();
                return _redraw();
              }
          }
        });

        dprint('Main User is signed in!');
        firebaseInitApp(context);
        firebaseGetToken(context);
        listenChat(user);
        FirebaseFirestore.instance.collection("messages")
            .where('user', isEqualTo: user.uid).where("read", isEqualTo: false )
            .get().then((querySnapshot) {
          numberOfUnreadMessages = querySnapshot.size;
        });
        dprint("user.email=${user.email}");
        if (user.email != null)
          userEmail = user.email!;
        dprint("user phone = ${user.phoneNumber}");
       await checknewuser();
       _redraw();
       if(newuser==false)
        FirebaseFirestore.instance.collection("listusers").doc(user.uid).get().then((querySnapshot) async {
          if (querySnapshot.exists){
            var data = querySnapshot.data()!;
            userName = (data["name"]  != null) ? data["name"] : "";
            userPhone = (data["phone"]  != null) ? data["phone"] : "";
            userAvatar = (data["logoServerPath"]  != null) ? data["logoServerPath"] : "";
            userSocialLogin = (data["socialLogin"]  != null) ? data["socialLogin"] : "";
            _subscription=(data["subscription"]!=null)? data["subscription"]:false; //subscription change
            if (data["address"] != null)
              List.from(data['address']).forEach((element){
                userAddress.add(AddressData.fromJson(element));
              });
            // favorites
            if (data['userFavorites'] != null)
              for (dynamic key in data['userFavorites']){
                userFavorites.add(key.toString());
              }
            _redraw();
            userAccount.initProviderDistances();
            comboBoxInitAddress(this);
          }
        });
      }
    });
  }

  List<MessageData> messages = [];

  Future<String?> loadMessages() async{
    try{
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null)
        return "not register";

      var querySnapshot = await FirebaseFirestore.instance.collection("messages").where('user', isEqualTo: user.uid).get();
      messages = [];
      querySnapshot.docs.forEach((result) {
        dprint("loadMessages");
        dprint(result.data().toString());
        dprint(result.data()["time"].toDate().toString());
        messages.add(MessageData(result.id, result.data()["title"], result.data()["body"], result.data()["time"].toDate().toLocal()));
      });

      messages.sort((a, b) => a.compareTo(b));
      _setToRead(user);
    }catch(ex){
      return "loadMessages " + ex.toString();
    }
    return null;
  }

  _setToRead(User user){
    FirebaseFirestore.instance.collection("messages").where('user', isEqualTo: user.uid).where('read', isEqualTo: false)
        .get().then((querySnapshot) {
      querySnapshot.docs.forEach((result) {
        print(result.data());
        FirebaseFirestore.instance.collection("messages").doc(result.id).set({
          "read": true,
        }, SetOptions(merge:true)).then((value2) {});
      });
    });
  }

  deleteMessage(MessageData item) async {
    try{
      await FirebaseFirestore.instance.collection("messages").doc(item.id).delete();
      messages.remove(item);
    }catch(ex){
      return "deleteMessage " + ex.toString();
    }
    return null;
  }

  _getChatRoomId(String a, String b,bool bo) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)){
      return "$b\_$a";
     } else {
      if(bo)
      return "$a\_$b";
      else
        return "$b\_$a";
   }
  }

  Future<String?> loadUsers() async{
    try{
      var querySnapshot = await FirebaseFirestore.instance.collection("listusers").get();
      users = [];
      querySnapshot.docs.forEach((result) {
        var _data = result.data();
        //print("User $_data");
        users.add(UserData.fromJson(result.id, _data));
      });
    }catch(ex){
      return "loadUsers " + ex.toString();
    }
    return null;
  }

  List<UserData> customersChat = [];

  _createChatUsersList(){
    var user = FirebaseAuth.instance.currentUser;
    if (user == null)
      return;
    dprint("_createChatUsersList -----------------------------------");
    customersChat = [];
    for (var item in users){
      if (item.id == user.uid)
        continue;
      dprint("${item.email} ${item.providerApp}");
      if (item.providerApp) {
        for (var item2 in provider) {
          if (item2.login == item.email) {
            item.name = getTextByLocale(item2.name);
            item.logoServerPath = item2.logoServerPath;
            break;
          }
        }
        dprint("add");
        customersChat.add(item);
        continue;
      }
      if (item.role.isNotEmpty) {
        dprint("add");
        customersChat.add(item);
      }
    }
    dprint("_createChatUsersList -----------------------------------");
  }

  Future<String?> getChatMessages(Function() _redraw) async {
    var _unread = 0;
    try{
      _createChatUsersList();
      var user = FirebaseAuth.instance.currentUser;
      if (user == null)
        return "user == null";
      for (var item in customersChat) {
        var data = await FirebaseFirestore.instance.collection("chatRoom").doc(
            _getChatRoomId(item.id, user.uid,true)).get();
        if (data.data() != null) {
          var _data = data.data()!;
          item.all = (_data['all'] != null) ? _data['all'] : 0;
          item.unread = (_data['unread_${user.uid}'] != null) ? _data['unread_${user.uid}'] : 0;
          item.lastMessage = (_data['last_message'] != null) ? _data['last_message'] : "";
          item.lastMessageTime = (_data['last_message_time'] != null) ? _data['last_message_time'].toDate().toLocal() : DateTime.now();
          _unread += item.unread;
        }
        item.listen = FirebaseFirestore.instance.collection("chatRoom")
            .doc(_getChatRoomId(item.id, user.uid,true)).snapshots().listen((querySnapshot) async {
          if (querySnapshot.data() != null) {
            var _data = querySnapshot.data()!;
            item.all = (_data['all'] != null) ? _data['all'] : 0;
            item.unread = (_data['unread_${user.uid}'] != null) ? _data['unread_${user.uid}'] : 0;
            item.lastMessage = (_data['last_message'] != null) ? _data['last_message'] : "";
            item.lastMessageTime = (_data['last_message_time'] != null) ? _data['last_message_time'].toDate().toLocal() : DateTime.now();
            if (chatId == item.id) {
              if (item.unread != 0) {
                await FirebaseFirestore.instance.collection("chatRoom").doc(_getChatRoomId(item.id, user.uid,true)).set({
                  "unread_${user.uid}": 0,}, SetOptions(merge: true));
                await FirebaseFirestore.instance.collection("listusers").doc(user.uid).set({
                  "unread_chat": FieldValue.increment(-item.unread),
                }, SetOptions(merge: true));
              }
            }
            customersChat.sort((a, b) => a.compareToAll(b));
            customersChat.sort((a, b) => a.compareToUnread(b));
            notifyListeners();
          }
        });
      }
      customersChat.sort((a, b) => a.compareToAll(b));
      customersChat.sort((a, b) => a.compareToUnread(b));
      if (_unread != chatCount)
        await FirebaseFirestore.instance.collection("listusers").doc(user.uid).set({
          "unread_chat": _unread,
        }, SetOptions(merge: true));
    }catch(ex){
      return "getChatMessages " + ex.toString();
    }
    return null;
  }

  String chatName = "";
  int unread = 0;
  String chatLogo = "";
  String chatId = "";

  setChatData(String _title, int _unread, String _logo, String _chatId){
    chatName = _title;
    unread = _unread;
    chatLogo = _logo;
    chatId = _chatId;
  }

  String chatRoomId = "";
  Stream<QuerySnapshot>? chats;

  Future<String?> initChat(Function() _redraw) async {
    try{
      User? user = FirebaseAuth.instance.currentUser;
      List<String> users = [user!.uid, chatId];

      chatRoomId = _getChatRoomId(user.uid, chatId,false);
      Map<String, dynamic> chatRoom = {
        "users": users,
        "chatRoomId" : chatRoomId,
      };
      chats = null;
      await FirebaseFirestore.instance
          .collection("chatRoom")
          .doc(chatRoomId)
          .set(chatRoom, SetOptions(merge:true));
      _getChats(_redraw);
    }catch(ex){
      return "initChat " + ex.toString();
    }
    _redraw();
    return null;
  }

  _getChats(Function() _redraw) async {
    try{
      chats = FirebaseFirestore.instance
          .collection("chatRoom")
          .doc(chatRoomId)
          .collection("chats")
          .orderBy('time')
          .snapshots();
      _redraw();
      User? user = FirebaseAuth.instance.currentUser;
      FirebaseFirestore.instance.collection("chatRoom").doc(chatRoomId).set({
        "unread_${user!.uid}" : 0,
      }, SetOptions(merge:true));
      await FirebaseFirestore.instance.collection("listusers").doc(user.uid).set({
        "unread_chat": FieldValue.increment(-unread),
      }, SetOptions(merge: true));
    }catch(ex){
      return "_getChats " + ex.toString();
    }
  }

  Future<String?> addMessage(String text) async{
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null)
      return "User == null";

    try{
      Map<String, dynamic> chatMessageMap = {
        "sendBy": user.uid,
        'read': false,
        "message": text,
        'time': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection("chatRoom")
          .doc(chatRoomId)
          .collection("chats")
          .add(chatMessageMap);

      await FirebaseFirestore.instance.collection("chatRoom").doc(chatRoomId).set({
        "all": FieldValue.increment(1),
        "unread_$chatId": FieldValue.increment(1),
        "last_message": text,
        "last_message_time": FieldValue.serverTimestamp(),
        "last_message_from": user.uid,
        }, SetOptions(merge: true));

      await FirebaseFirestore.instance.collection("listusers").doc(chatId).set({
        "unread_chat": FieldValue.increment(1),
      }, SetOptions(merge: true));

      sendMessage(text, strings.get(156), chatId); /// "Chat message"

    }catch(ex){
      return "addMessage " + ex.toString();
    }
    return null;
  }



  Future<String?> finish(String paymentMethod, MainModel _mainModel) async{
    if (currentService.providers.isEmpty)
      return "currentService.providers.isEmpty";
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null)
      return "user == null";
    dprint("send data");

    List<AddonData> _addon = [];
    if (_mainModel.currentService.addon.isNotEmpty)
      for (var item in _mainModel.currentService.addon) {
        if (!item.selected)
          continue;
        _addon.add(item);
      }

    try{
      var _provider = ProviderData.createEmpty();
      for (var item in provider)
        if (item.id == currentService.providers[0])
          _provider = item;
      if (_provider.id.isEmpty)
        return "Provider not found. _provider.id.isEmpty";
      if (localAppSettings.statuses.isEmpty)
        return "Statuses is empty. localAppSettings.statuses.isEmpty";
      var _data = BookingData(
        status: currentService.name.first.text.contains("Subscription")?"5":localAppSettings.statuses[0].id,
          finished: currentService.name.first.text.contains("Subscription")?true:false,
        history: [StatusHistory(
            statusId: localAppSettings.statuses[0].id,
            time: DateTime.now(),
            byCustomer: true,
            activateUserId : user.uid
        )],
        customerId: user.uid,
        customer: userName,
        customerAvatar: userAvatar,
        providerId: _provider.id,
        provider: _provider.name,
        providerPhone: _provider.phone,
        providerAvatar: _provider.imageUpperServerPath,
        serviceId: currentService.id,
        service: currentService.name,
        // price
        price:_mainModel.getSubvalue()?localSettings.getTotal(_mainModel):localSettings.price.price,
        discPrice: _mainModel.getSubvalue()?localSettings.getTotal(_mainModel):localSettings.price.discPrice,
        priceUnit: localSettings.price.priceUnit,
        count: localSettings.count,
        priceName: localSettings.price.name,
        // coupon
        couponId: localSettings.coupon == null ? "" : localSettings.coupon!.id,
        couponName: localSettings.coupon == null ? "" : localSettings.coupon!.code,
        discount: localSettings.coupon == null ? 0 : localSettings.coupon!.discount,
        discountType: localSettings.coupon == null ? "fixed" : localSettings.coupon!.discountType,
        //
        tax: currentService.tax,
        taxAdmin: currentService.taxAdmin,
        total: localSettings.getTotal(this),
        paymentMethod:_mainModel.getSubvalue()?_mainModel.getSubtypevalue():paymentMethod,
        //
        comment: localSettings.hint,
        address: userAccount.getCurrentAddress().address,
        anyTime: localSettings.anyTime,
        selectTime: localSettings.selectTime,
        //
        time: DateTime.now(),
        viewByAdmin: false,
        viewByProvider: false,
        //
        addon: _addon
      ).toJson();
      await FirebaseFirestore.instance.collection("booking").add(_data);
      if(!currentService.name.first.text.contains("Subscription")){
      await FirebaseFirestore.instance.collection("settings").doc("main")
          .set({"booking_count": FieldValue.increment(1)}, SetOptions(merge:true));
      await FirebaseFirestore.instance.collection("settings").doc("main")
          .set({"booking_count_unread": FieldValue.increment(1)}, SetOptions(merge:true));
      }
      if(currentService.name.first.text.contains("Subscription")){    //subscription change
        DateTime dt=DateTime.now();
       // dt=dt.add(Duration(minutes: 1));
       dt=dt.add(Duration(days: 365));
        await FirebaseFirestore.instance.collection("listusers").doc(user.uid).set({
          "subscription": true,
          "subscriptiontype":currentService.name.first.text.split(" ").first,
          "Subscription End":dt.toString(),
      }, SetOptions(merge: true));
        await _addagentcomission();
      await updatesubscriptiondetail(user);
      }
      sendMessage("${strings.get(160)} $userName",  /// "From user:",
          strings.get(157),  /// "New Booking was arrived",
          getProviderId(_provider.login));
    }catch(ex){
      dprint(ex.toString());
      return "finish " + ex.toString();
    }
    return null;
  }

  void checksubscriptionend() async{
    print("Subscription Status: "+_subscription.toString());
    DateTime dd=DateTime.now();
    User? user=FirebaseAuth.instance.currentUser;
    if(user!=null){
      var snap=await FirebaseFirestore.instance.collection("listusers").doc(user.uid).get();
      var data=snap.data();
      if(data!=null) {
        if (data["Subscription End"] != null) {
          DateTime checkdate = DateTime.parse(data["Subscription End"]);
          if (dd.isAfter(checkdate))
            await FirebaseFirestore.instance.collection("listusers").doc(
                user.uid).set({
              "subscription": false,
              "subscriptiontype":"",
            }, SetOptions(merge: true));
        }
      }
      await updatesubscriptiondetail(user);
    }
    //print(_subscription);
  }


  Future updatesubscriptiondetail(User user)async {                 //subscription change
    try{
      await FirebaseFirestore.instance.collection("listusers").doc(user.uid).get().then((querySnapshot) async {
        if (querySnapshot.exists){
          var data = querySnapshot.data()!;
          _subscription=(data["subscription"]!=null)? data["subscription"]:false;
          _subscriptiontype=(data["subscriptiontype"]!=null)? data["subscriptiontype"]:"";
        }
        print("subscription updated: "+_subscription.toString());
      });
    }catch(e){
      print("subscription update error");
      print(e.toString());
    }
  }

  Future _addagentcomission() async{
    try {
      String agentid = "";
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        var t = await FirebaseFirestore.instance.collection("listusers").doc(
            user.uid).get();
        var data = t.data();
        if (data != null)
          agentid =
          data['agent referrel'] != null? data['agent referrel'] : "";
      }

      var auid = await FirebaseFirestore.instance.collection("agents").doc(
          agentid).get(); //Adding agent payout\
      var agentdata=auid.data();

      double previouspayout=0.0;

      if(agentdata!=null) {
        String s=agentdata['commission']!=null?agentdata['commission']:"";
        if(s.isNotEmpty)
        previouspayout = double.parse(s);
      }
      //print("previous price"+ previouspayout.toString());

      double newpayout = previouspayout+((localSettings.price.discPrice * 20) / 100);

      await FirebaseFirestore.instance.collection("agents").doc(auid.id).set({
        "commission": newpayout.toString(),
      }, SetOptions(merge: true));

      print("Commission added");
    }
    catch(e){
      print("Agent Payout:"+e.toString());
    }

  }




  List<BookingData> booking = [];

  Function()? _jobInfoListen;
  setJobInfoListen(Function() jobInfoListen){
    _jobInfoListen = jobInfoListen;
  }

  // ignore: cancel_subscriptions
  StreamSubscription? _listenBooking;

  Future<String?> listenBooking(Function() _redraw) async{
    try{
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null)
        return "not register";
      _listenBooking = FirebaseFirestore.instance.collection("booking")
          .where('customerId', isEqualTo: user.uid).snapshots().listen((querySnapshot) {
        booking = [];
        querySnapshot.docs.forEach((result) {
          booking.add(BookingData.fromJson(result.id, result.data()));
        });
        for (var item in booking)
          for (var item2 in item.addon)
            item2.selected = true;
        booking.sort((a, b) => b.time.compareTo(a.time));
        if (_jobInfoListen != null) {
          for (var item in booking)
            if (item.id == localSettings.jobInfo.id)
              localSettings.jobInfo = item;
          _jobInfoListen!();
        }
        _redraw();
      });
    }catch(ex){
      return "listenBooking " + ex.toString();
    }
    return null;
  }

  Future<String?> changePassword(String password) async{
    try{
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null)
        return "user == null";
      await user.updatePassword(password);
    }catch(ex){
      return "changePassword " + ex.toString();
    }
    return null;
  }

  Future<String?> changeInfo(String name, String email, String phone) async{
    try{
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null)
        return "user == null";
      if (userSocialLogin.isEmpty)
        await user.updateEmail(email);
      await FirebaseFirestore.instance.collection("listusers").doc(user.uid).set({
        "name": name,
        "phone": phone,
        "email": email
      }, SetOptions(merge:true));
      userPhone = phone;
      userEmail = email;
      userName = name;
    }catch(ex){
      return "changeInfo " + ex.toString();
    }
    return null;
  }

  Future<String?> googleLogin() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;
      final googleAuthCredential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      userSocialLogin = "google";
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(googleAuthCredential);
      if (userCredential.user == null)
        return "userCredential.user == null";

      var querySnapshot = await FirebaseFirestore.instance.collection("listusers").doc(userCredential.user!.uid).get();
      var data = querySnapshot.data();
      if (data != null && data.isNotEmpty)
        return null;

      FirebaseFirestore.instance.collection("listusers").doc(userCredential.user!.uid).set({
        "visible": true,
        "phoneVerified": false,
        "email": userCredential.user!.email,
        "phone": "",
        "name": userCredential.user!.displayName,
        "date_create" : FieldValue.serverTimestamp(),
        "socialLogin" : "google",
        "subscription": false //subscription change
      });

      dprint("Sign In ${userCredential.user} with Google");
    } catch (ex) {
      return "googleLogin " + ex.toString();
    }
    return null;
  }

  Future<String?> facebookLogin() async {
    try {
      await FacebookAuth.instance.logOut();
      LoginResult result = await FacebookAuth.instance.login();

      userSocialLogin = "facebook";

      final AuthCredential credential = FacebookAuthProvider.credential(  // String accessToken
        result.accessToken!.token,
      );
      var t = await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = t.user;
      if (user == null)
        return "user == null";

      var querySnapshot = await FirebaseFirestore.instance.collection("listusers").doc(user.uid).get();
      var data = querySnapshot.data();
      if (data != null && data.isNotEmpty)
        return null;

      FirebaseFirestore.instance.collection("listusers").doc(user.uid).set({
        "visible": true,
        "phoneVerified": false,
        "email": user.email,
        "phone": "",
        "name": user.displayName,
        "date_create" : FieldValue.serverTimestamp(),
        "socialLogin" : "facebook",
        "subscription":false //subscription change
      });
      //_message("Sign In ${user!.uid} with Facebook");
    } catch (ex) {
      return "facebookLogin " + ex.toString();
    }
    return null;
  }

  String generateNonce([int length = 32]) {
    final charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  // String sha256ofString(String input) {
  //   final bytes = utf8.encode(input);
  //   final digest = sha256.convert(bytes);
  //   return digest.toString();
  // }

  Future<String?> appleLogin(AuthorizationCredentialAppleID? _credential) async {
    if (_credential == null)
      return "credential == null";
    try {

      userSocialLogin = "apple";

      final rawNonce = generateNonce();
      // final nonce = sha256ofString(rawNonce);

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: _credential.identityToken,
        rawNonce: rawNonce,
      );

      var t = await FirebaseAuth.instance.signInWithCredential(oauthCredential);
      final User? user = t.user;
      if (user == null)
        return "user == null";

      var querySnapshot = await FirebaseFirestore.instance.collection("listusers").doc(user.uid).get();
      var data = querySnapshot.data();
      if (data != null && data.isNotEmpty)
        return null;

      FirebaseFirestore.instance.collection("listusers").doc(user.uid).set({
        "visible": true,
        "phoneVerified": false,
        "email": user.email,
        "phone": "",
        "name": user.displayName != null ? user.displayName : "",
        "date_create" : FieldValue.serverTimestamp(),
        "socialLogin" : "apple",
        "subscription":false //subscription change
      });
    } catch (e) {
      print(e);
      return "appleLogin " + e.toString();
    }
    return null;
  }

  // ignore: cancel_subscriptions
  StreamSubscription<DocumentSnapshot>? _listen;

  disposeChatNotify(){
    if (_listen != null)
      _listen!.cancel();
  }

  listenChat(User? user){
    _listen = FirebaseFirestore.instance.collection("listusers")
        .doc(user!.uid).snapshots().listen((querySnapshot) {
      if (querySnapshot.data() != null) {
        var _data = querySnapshot.data()!;
        print(_data["unread_chat"]);
        chatCount = _data["unread_chat"] != null ? toDouble(_data["unread_chat"].toString()).toInt() : 0;
        if (chatCount < 0) {
          chatCount = 0;
          FirebaseFirestore.instance.collection("listusers").doc(user.uid).set({
            "unread_chat": chatCount,
          }, SetOptions(merge: true));
        }
        notifyListeners();
      }
    });
  }

  Future<String?> sendMessage(String _body, String _title, String _toId) async {

    String _to = "";
    for (var item in users)
      if (item.id == _toId) {
        _to = item.fcb;
        break;
      }
    if (_to.isEmpty)
      return null;

    var pathFCM = 'https://fcm.googleapis.com/fcm/send';

    String _key = localAppSettings.cloudKey;
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': "application/json",
      'Authorization': "key=$_key",
    };

    var body = json.encoder.convert({
      'notification': {
        'body': "$_body", 'title': "$_title", 'click_action': 'FLUTTER_NOTIFICATION_CLICK', 'sound': 'default'
      },
      'priority': 'high',
      'sound': 'default',
      'data': {
        'body': "$_body", 'title': "$_title", 'click_action': 'FLUTTER_NOTIFICATION_CLICK', 'sound': 'default'
      },
      'to': "$_to",
    });

    dprint('body: $body');
    var response = await http.post(Uri.parse(pathFCM), headers: requestHeaders, body: body).timeout(const Duration(seconds: 30));

    dprint('Response status: ${response.statusCode}');
    dprint('Response body: ${response.body}');

    if (response.statusCode == 200){
      var jsonResult = json.decode(response.body);
      if (jsonResult["success"] == 1){
        // write to db
        try {
          await FirebaseFirestore.instance.collection("messages").add(
              {
                "time": FieldValue.serverTimestamp(),
                "title": "$_title",
                "body": "$_body",
                "user": _toId,
                "read": false
              });
        }catch(ex){
          return "sendMessage " + ex.toString();
        }
        return null;
      }
      return "sendMessage ${jsonResult["results"]}";
    }
    return "sendMessage response.statusCode=${response.statusCode}";
  }



  Future<String?> nextStep(StatusData status) async{
    StatusData _last = StatusData.createEmpty();
    for (var item in localAppSettings.statuses) {
      if (!item.cancel)
        _last = item;
    }
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null)
      return "nextStep user == null";
    try{
      localSettings.jobInfo.history.add(StatusHistory(
          statusId: status.id,
          time: DateTime.now(),
          byCustomer: true,
          activateUserId : user.uid
      ));
      var _finished = localSettings.jobInfo.finished;
      if (!status.cancel)
        if (status.id == _last.id)
          _finished = true;
      await FirebaseFirestore.instance.collection("booking").doc(localSettings.jobInfo.id).set({
        "status": status.id,
        "history": localSettings.jobInfo.history.map((i) => i.toJson()).toList(),
        "finished" : _finished
      }, SetOptions(merge:true));
      localSettings.jobInfo.status = status.id;
      sendMessage("${strings.get(158)} ${getTextByLocale(status.name)}",  /// "Now status:",
          strings.get(159),  /// "Booking status was changed",
          localSettings.jobInfo.customerId);
    }catch(ex){
      return "nextStep " + ex.toString();
    }
    return null;
  }

  bool isPassed(StatusData item){
    for (var item2 in localSettings.jobInfo.history){
      if (item2.statusId == item.id)
        return true;
    }
    return false;
  }

  StatusHistory? cancelItem(StatusData item){
    for (var item2 in localSettings.jobInfo.history){
      if (item2.statusId == item.id)
        return item2;
    }
    return null;
  }

  Future<String?> addRating(int rating, String text, List<String> images) async{
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null)
      return "addRating user == null";
    List<ImageData> _images = [];
    try{
      for (var item in images){
        var f = Uuid().v4();
        var name = "rate/$f.jpg";
        var firebaseStorageRef = FirebaseStorage.instance.ref().child(name);
        TaskSnapshot s = await firebaseStorageRef.putFile(File(item));
        _images.add(ImageData(localFile: name, serverPath: await s.ref.getDownloadURL()));
      }
      //
      await FirebaseFirestore.instance.collection("service").doc(localSettings.jobInfo.serviceId).set({
        "rating$rating": FieldValue.increment(1),
      }, SetOptions(merge:true));
      await FirebaseFirestore.instance.collection("reviews").add({
        "rating": rating,
        "text": text,
        "images": _images.map((i) => i.toJson()).toList(),
        "user": user.uid,
        "service": localSettings.jobInfo.serviceId,
        'serviceName': getTextByLocale(localSettings.jobInfo.service),
        "provider": localSettings.jobInfo.providerId,
        "userName": userName,
        "userAvatar": userAvatar,
        'time': FieldValue.serverTimestamp(),
      });
      await FirebaseFirestore.instance.collection("booking").doc(localSettings.jobInfo.id).set({
        "rated": true,
      }, SetOptions(merge:true));
      await FirebaseFirestore.instance.collection("settings").doc("main")
          .set({"service_reviews": FieldValue.increment(1)}, SetOptions(merge:true));
    } catch (e) {
      return "addRating " + e.toString();
    }
    localSettings.jobInfo.rated = true;
    return null;
  }

  List<ReviewsData> reviews = [];

  Future<String?> loadReviews() async{
    try{
      var querySnapshot = await FirebaseFirestore.instance.collection("reviews")
          .where("service", isEqualTo: currentService.id).get();
      reviews = [];
      querySnapshot.docs.forEach((result) {
        var _data = result.data();
        print("loadReviews $_data");
        reviews.add(ReviewsData.fromJson(result.id, _data));
      });
    }catch(ex){
      return "model loadReviews " + ex.toString();
    }
    return null;
  }

  Future<String?> loadOffers() async{
    try{
      var querySnapshot = await FirebaseFirestore.instance.collection("offer").get();
      offers = [];
      querySnapshot.docs.forEach((result) {
        var _data = result.data();
        print("loadOffers $_data");
        offers.add(OfferData.fromJson(result.id, _data));
      });
    }catch(ex){
      return "loadOffers " + ex.toString();
    }
    return null;
  }

  String couponInfo(){
    OfferData? _item;
    dprint("<-------------couponInfo------------>");

    for (var item in offers) {
      dprint("offers = ${item.code} - need localSettings.couponCode=${localSettings.couponCode}");
      if (item.code == localSettings.couponCode) {
        _item = item;
        break;
      }
    }

    if (_item == null){
      dprint("coupon not found");
      localSettings.coupon = null;
      return strings.get(162); /// "Coupon not found",
    }
    //
    // Time
    //
    var _now = DateTime.now();
    dprint("time coupon ${_item.expired}");
    dprint("time    now $_now");
    dprint("is   before ${_item.expired.isBefore(_now)}");
    if (_item.expired.isBefore(_now)){
      dprint("Coupon has expired");
      localSettings.coupon = null;
      return strings.get(169); /// "Coupon has expired",
    }

    //
    // Provider
    //
    if (_item.providers.isNotEmpty){
      dprint("providers not empty");
      var _provider = ProviderData.createEmpty();
      for (var item in provider)
        if (item.id == currentService.providers[0])
          _provider = item;
      if (_provider.id.isEmpty) {
        localSettings.coupon = null;
        dprint("Provider not found. _provider.id.isEmpty!!!!");
        return "Provider not found. _provider.id.isEmpty";
      }

      var _found = false;
      for (var item in _item.providers){
        dprint("current provider id: ${_provider.id} - in list $item");
        if (item == _provider.id) {
          _found = true;
          break;
        }
      }
      if (!_found){
        dprint("Coupon not supported by this provider");
        localSettings.coupon = null;
        return strings.get(164); /// "Coupon not supported by this provider",
      }
    }else
      dprint("providers empty");

    //
    // Category
    //
    if (_item.category.isNotEmpty){
      dprint("category not empty");
      var _found = false;
      for (var item in _item.category){
        dprint("current provider id: ${currentService.category.join(" ")} - in list $item");
        if (currentService.category.contains(item)){
          _found = true;
          break;
        }
      }
      if (!_found){
        dprint("Coupon not support this category",);
        localSettings.coupon = null;
        return strings.get(165); /// "Coupon not support this category",
      }
    }else
      dprint("category empty");

    //
    // Service
    //
    if (_item.services.isNotEmpty){
      dprint("current provider id: ${currentService.id} - in list ${_item.services.join(" ")}");
      if (!_item.services.contains(currentService.id)){
        dprint("Coupon not support this service");
        localSettings.coupon = null;
        return strings.get(166); /// "Coupon not support this service",
      }
    }else
      dprint("service empty");

    dprint("Coupon activated");
    dprint("<-------------couponInfo------------>");
    localSettings.coupon = _item;
    return strings.get(163); /// "Coupon activated",
  }
}

getTheme() async {
  dprint("getTheme");
  try{
    var directory = await getApplicationDocumentsDirectory();
    var directoryPath = directory.path;
    var _file = File('$directoryPath/theme.json');
    if (await _file.exists()){
      final contents = await _file.readAsString();
      var data = json.decode(contents);
      dprint("getTheme $data");
      theme = OnDemandServiceTheme.fromJson(data);
    }else{
      dprint("getTheme - file $directoryPath/theme.json not found");
      await getThemeFromServer();
    }
  }catch(ex){
    print("getTheme $ex");
  }
}

bool themeFromServerLoad = false;

getThemeFromServer() async {
  try{
    dprint("getThemeFromServer");
    var directory = await getApplicationDocumentsDirectory();
    var directoryPath = directory.path;
    var querySnapshot = await FirebaseFirestore.instance.collection("settings").doc("serviceApp").get();
    theme = OnDemandServiceTheme.fromJson(querySnapshot.data()!);
    // save local
    var _t = json.encode(theme.toJson());
    await File('$directoryPath/theme.json').writeAsString(_t);
    themeFromServerLoad = true;
    dprint("getThemeFromServer save $directoryPath/theme.json");
  }catch(ex){
    print("getThemeFromServer $ex");
  }
}

class StringData{
  String code = "";
  String text = "";

  StringData({this.code = "", this.text = ""});

  Map<String, dynamic> toJson() => {
    'code': code,
    'text': text,
  };

  factory StringData.fromJson(Map<String, dynamic> data){
    return StringData(
      code: (data["code"] != null) ? data["code"] : "",
      text: (data["text"] != null) ? data["text"] : "",
    );
  }

  factory StringData.createEmpty(){
    return StringData();
  }
}

class ImageData{
  String serverPath = "";
  String localFile = "";

  ImageData({this.serverPath = "", this.localFile = ""});

  Map<String, dynamic> toJson() => {
    'serverPath': serverPath,
    'localFile': localFile,
  };

  factory ImageData.fromJson(Map<String, dynamic> data){
    return ImageData(
      serverPath: (data["serverPath"] != null) ? data["serverPath"] : "",
      localFile: (data["localFile"] != null) ? data["localFile"] : "",
    );
  }

  factory ImageData.createEmpty(){
    return ImageData();
  }
}


class MessageData{
  MessageData(this.id, this.title, this.body, this.time);
  final String id;
  final String title;
  final String body;
  final DateTime time;

  int compareTo(MessageData b){
    if (time.isAfter(b.time))
      return -1;
    if (time.isBefore(b.time))
      return 1;
    return 0;
  }
}


class ReviewsData{
  final String id;
  final int rating;
  final String text;
  List<ImageData> images = [];
  final String user;
  final String serviceId;
  final String serviceName;
  final String providerId;
  final String userName;
  final String userAvatar;
  final DateTime time;

  ReviewsData({this.id = "", this.rating = 0, this.text = "", required this.images, this.user = "",
    this.serviceId = "", this.serviceName = "", this.providerId = "", this.userName = "",
    this.userAvatar = "", required this.time});

  Map<String, dynamic> toJson() => {
    "rating": rating,
    "text": text,
    "images": images.map((i) => i.toJson()).toList(),
    "user": user,
    "service": serviceId,
    'serviceName': serviceName,
    "provider": providerId,
    "userName": userName,
    "userAvatar": userAvatar,
    "time" : time
  };

  factory ReviewsData.fromJson(String _id, Map<String, dynamic> data){
    List<ImageData> _images = [];
    if (data['images'] != null)
      List.from(data['images']).forEach((element){
        _images.add(ImageData(serverPath: element["serverPath"], localFile: element["localFile"]));
      });
    return ReviewsData(
      id : _id,
      rating: (data["rating"] != null) ? data["rating"] : 0,
      text: (data["text"] != null) ? data["text"] : "",
      images: _images,
      user: (data["user"] != null) ? data["user"] : "",
      serviceId: (data["service"] != null) ? data["service"] : "",
      serviceName: (data["serviceName"] != null) ? data["serviceName"] : "",
      providerId: (data["provider"] != null) ? data["provider"] : "",
      userName: (data["userName"] != null) ? data["userName"] : "",
      userAvatar: (data["userAvatar"] != null) ? data["userAvatar"] : "",
      time: (data["time"] != null) ? data["time"].toDate().toLocal() : DateTime.now(),
    );
  }
}

