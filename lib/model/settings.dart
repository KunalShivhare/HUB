import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as df;
import 'package:ondemandservice/model/service.dart';
import 'package:ondemandservice/util.dart';

import 'model.dart';

class AppSettings{

  int ver;
  int langVer;
  //
  bool demo = false;
  bool rightSymbol = false;
  int digitsAfterComma = 2;
  String code = "USD";
  String symbol = "\$";
  String distanceUnit = "km";
  String timeFormat = "24h";
  getTimeFormat(){
    if (timeFormat == "12h")
      return 'hh:mm a';
    return 'HH:mm';
  }
  String dateFormat = "yyyy.MM.dd";
  String getDateTimeString(DateTime _time){
    return df.DateFormat(dateFormat).format(_time).toString() + " " +
        df.DateFormat(getTimeFormat()).format(_time).toString();
  }
  String googleMapApiKey = "";
  String cloudKey = "";
  String copyright = "";
  String policy = "";
  String about = "";
  String terms = "";
  String googlePlayLink = "";
  String appStoreLink = "";
  //
  bool stripeEnable = false;
  String stripeKey = "";
  String stripeSecretKey = "";
  bool paypalEnable = false;
  String paypalSecretKey = "";
  String paypalClientId = "";
  bool paypalSandBox = false;
  bool razorpayEnable = false;
  String razorpayName = "";
  String razorpayKey = "";
  // payStack
  bool payStackEnable = false;
  String payStackKey = "";
  // FlutterWave
  bool flutterWaveEnable = false;
  String flutterWaveEncryptionKey = "";
  String flutterWavePublicKey = "";
  //
  bool otpEnable = false;
  String otpPrefix = "";
  int otpNumber = 10;
  bool otpTwilioEnable = false;
  String twilioAccountSID = "";
  String twilioAuthToken = "";
  String twilioServiceId = "";
  // nexmo
  bool otpNexmoEnable = false;
  String nexmoFrom = "";
  String nexmoText = "";
  String nexmoApiKey = "";
  String nexmoApiSecret = "";
  // smsTo
  bool otpSMSToEnable = false;
  String smsToFrom = "";
  String smsToText = "";
  String smsToApiKey = "";
  //
  String defaultServiceAppLanguage = "en";
  String defaultProviderAppLanguage = "en";
  String currentServiceAppLanguage = "";
  List<String> inMainScreenServices = [];
  List<String> customerAppElements = [];
  List<String> customerAppElementsDisabled = [];
  //
  List<StatusData> statuses = statusesData;
  String getStatusName(String id){
    for (var item in statuses)
      if (item.id == id)
        return getTextByLocale(item.name);
    return "???";
  }

  bool isOtpEnable(){
    return (otpEnable || otpTwilioEnable || otpNexmoEnable || otpSMSToEnable);
  }

  //
  AppSettings({this.ver = 1, this.langVer = 0, this.demo = false, this.rightSymbol = false,
    this.digitsAfterComma = 2, this.code = "USD", this.symbol = "\$",
    this.distanceUnit = "km", this.timeFormat = "24h", this.dateFormat = "yyyy.MM.dd",
    this.googleMapApiKey = "", this.cloudKey = "", this.copyright = "", this.policy = "",
    this.about = "", this.terms = "", this.googlePlayLink = "", this.appStoreLink = "",
    this.stripeEnable = false, this.stripeKey = "", this.stripeSecretKey = "",
    this.paypalEnable = false, this.paypalSecretKey = "", this.paypalClientId = "",
    this.razorpayEnable = false, this.razorpayName = "", this.razorpayKey = "",
    this.otpEnable = false, this.otpPrefix = "", this.otpNumber = 10,
    this.defaultServiceAppLanguage = "en", this.defaultProviderAppLanguage = "en",
    this.currentServiceAppLanguage = "", required this.statuses,
    this.twilioAccountSID = "", this.twilioAuthToken = "", this.twilioServiceId = "",
    this.otpTwilioEnable = false, this.paypalSandBox = true,
    this.otpNexmoEnable = false, this.nexmoFrom = "", this.nexmoText = "",
    this.nexmoApiKey = "", this.nexmoApiSecret = "", this.otpSMSToEnable = false,
    this.smsToFrom = "", this.smsToText = "", this.smsToApiKey = ""
  });

  Map toJson() => {
    'ver' : ver,
    'lang_ver' : langVer,
    'demo' : demo,
    'rightSymbol' : rightSymbol,
    'digitsAfterComma' : digitsAfterComma,
    'code' : code,
    'symbol' : symbol,
    'distanceUnit' : distanceUnit,
    'timeFormat' : timeFormat,
    'dateFormat' : dateFormat,
    'googleMapApiKey' : googleMapApiKey,
    'cloudKey' : cloudKey,
    'copyright' : copyright,
    'policy' : policy,
    'about' : about,
    'terms' : terms,
    'googlePlayLink' : googlePlayLink,
    'appStoreLink' : appStoreLink,
    'stripeEnable' : stripeEnable,
    'stripeKey' : stripeKey,
    'stripeSecretKey' : stripeSecretKey,
    'paypalEnable' : paypalEnable,
    'paypalSecretKey' : paypalSecretKey,
    'paypalClientId' : paypalClientId,
    'razorpayEnable' : razorpayEnable,
    'razorpayName' : razorpayName,
    'razorpayKey' : razorpayKey,
    'otpEnable' : otpEnable,
    'otpPrefix' : otpPrefix,
    'otpNumber' : otpNumber,
    'otpTwilioEnable' : otpTwilioEnable,
    'twilioAccountSID': twilioAccountSID,
    'twilioAuthToken': twilioAuthToken,
    'twilioServiceId': twilioServiceId,
    // nexmo
    "otpNexmoEnable" : otpNexmoEnable,
    "nexmoFrom" : nexmoFrom,
    "nexmoText" : nexmoText,
    "nexmoApiKey" : nexmoApiKey,
    "nexmoApiSecret" : nexmoApiSecret,
    // sms.to
    "otpSMSToEnable" : otpSMSToEnable,
    "smsToFrom" : smsToFrom,
    "smsToText" : smsToText,
    "smsToApiKey" : smsToApiKey,
    //
    'defaultServiceAppLanguage' : defaultServiceAppLanguage,
    'defaultProviderAppLanguage' : defaultProviderAppLanguage,
    'currentServiceAppLanguage' : currentServiceAppLanguage,
    'paypalSandBox' : paypalSandBox,
  };

  factory AppSettings.fromJson(Map<String, dynamic> data){
    List<StatusData> _statuses = [];
    if (data['statuses'] != null)
      List.from(data['statuses']).forEach((element){
      _statuses.add(StatusData.fromJson(element));
      });
    else
      _statuses = statusesData;
    return AppSettings(
      ver: data["ver"] != null ? data["ver"] : 1,
      langVer: data["lang_ver"] != null ? data["lang_ver"] : 0,
      demo: data["demo"] != null ? data["demo"] : false,
      rightSymbol: data["rightSymbol"] != null ? data["rightSymbol"] : false,
      digitsAfterComma: data["digitsAfterComma"] != null ? data["digitsAfterComma"] : 2,
      code: data["code"] != null ? data["code"] : "USD",
      symbol: data["symbol"] != null ? data["symbol"] : "\$",
      distanceUnit: data["distanceUnit"] != null ? data["distanceUnit"] : "km",
      timeFormat: data["timeFormat"] != null ? data["timeFormat"] : "24h",
      dateFormat: data["dateFormat"] != null ? data["dateFormat"] : "yyyy.MM.dd",
      googleMapApiKey: data["googleMapApiKey"] != null ? data["googleMapApiKey"] : "",
      cloudKey: data["cloudKey"] != null ? data["cloudKey"] : "",
      copyright: data["copyright"] != null ? data["copyright"] : "",
      about: data["about"] != null ? data["about"] : "",
      policy: data["policy"] != null ? data["policy"] : "",
      terms: data["terms"] != null ? data["terms"] : "",
      // payments gateway
      stripeKey: data["stripe_key"] != null ? data["stripe_key"] : "",
      stripeSecretKey: data["stripe_secret_key"] != null ? data["stripe_secret_key"] : "",
      paypalSecretKey: data["paypal_secret_key"] != null ? data["paypal_secret_key"] : "",
      paypalClientId: data["paypal_client_id"] != null ? data["paypal_client_id"] : "",
      razorpayName: data["razorpay_name"] != null ? data["razorpay_name"] : "",
      razorpayKey: data["razorpay_key"] != null ? data["razorpay_key"] : "",
      stripeEnable: data["stripe_enable"] != null ? data["stripe_enable"] : false,
      razorpayEnable: data["razorpay_enable"] != null ? data["razorpay_enable"] : false,
      paypalEnable: data["paypal_enable"] != null ? data["paypal_enable"] : false,
      paypalSandBox: data["paypalSandBox"] != null ? data["paypalSandBox"] : true,
      //
      googlePlayLink: data["googlePlayLink"] != null ? data["googlePlayLink"] : "",
      appStoreLink: data["appStoreLink"] != null ? data["appStoreLink"] : "",
      //darkMode: data["darkMode"] != null ? data["darkMode"] : false,
      //
      otpEnable: data["otpEnable"] != null ? data["otpEnable"] : false,
      otpPrefix: data["otpPrefix"] != null ? data["otpPrefix"] : "",
      otpNumber: data["otpNumber"] != null ? data["otpNumber"] : 10,
      otpTwilioEnable: data["otpTwilioEnable"] != null ? data["otpTwilioEnable"] : false,
      twilioAccountSID: data["twilioAccountSID"] != null ? data["twilioAccountSID"] : "",
      twilioAuthToken: data["twilioAuthToken"] != null ? data["twilioAuthToken"] : "",
      twilioServiceId: data["twilioServiceId"] != null ? data["twilioServiceId"] : "",
      // nexmo
      otpNexmoEnable: data["otpNexmoEnable"] != null ? data["otpNexmoEnable"] : false,
      nexmoFrom: data["nexmoFrom"] != null ? data["nexmoFrom"] : "",
      nexmoText: data["nexmoText"] != null ? data["nexmoText"] : "",
      nexmoApiKey: data["nexmoApiKey"] != null ? data["nexmoApiKey"] : "",
      nexmoApiSecret: data["nexmoApiSecret"] != null ? data["nexmoApiSecret"] : "",
      // sms to
      otpSMSToEnable: data["otpSMSToEnable"] != null ? data["otpSMSToEnable"] : false,
      smsToFrom: data["smsToFrom"] != null ? data["smsToFrom"] : "",
      smsToText: data["smsToText"] != null ? data["smsToText"] : "",
      smsToApiKey: data["smsToApiKey"] != null ? data["smsToApiKey"] : "",
      //
      defaultServiceAppLanguage: data["defaultServiceAppLanguage"] != null ? data["defaultServiceAppLanguage"] : "en",
      defaultProviderAppLanguage: data["defaultProviderAppLanguage"] != null ? data["defaultProviderAppLanguage"] : "en",
      currentServiceAppLanguage: data["currentServiceAppLanguage"] != null ? data["currentServiceAppLanguage"] : "en",
      //
      statuses: _statuses,
    );
  }
  factory AppSettings.createEmpty(){
    return AppSettings(statuses: statusesData);
  }

  String getPriceString(double price){
    if (rightSymbol) {
      // dprint("getPriceString $price ${price.toStringAsFixed(2)}");
      // var t = price.toStringAsFixed(2);
      return "$symbol${price.toStringAsFixed(digitsAfterComma)}";
    }
    return "${price.toStringAsFixed(digitsAfterComma)}$symbol";
  }

  double getServiceMinPriceDouble(ServiceData item){
    double _price = double.maxFinite;
    for (var item in item.price) {
      if (item.discPrice != 0){
        if (item.discPrice < _price) {
          _price = item.discPrice;
        }
      }else
      if (item.price < _price)
        _price = item.price;
    }
    if (_price == double.maxFinite)
      _price = 0;
    return _price;
  }

  String getServiceMinPrice(ServiceData item){
    return getPriceString(getServiceMinPriceDouble(item));
  }

}

class LangData{
  LangData({required this.name, required this.engName, this.image = "",
    required this.direction, required this.locale, this.app = "service", required this.data});
  String name;
  String engName;
  String image;
  TextDirection direction;
  String locale;
  String app;
  Map<String, dynamic> data;

  Map toJson() => {
    'name' : name,
    'engName' : engName,
    'direction' : direction == TextDirection.ltr ? "ltr" : 'rtl',
    'locale' : locale,
    'app' : app
  };

  factory LangData.fromJson(Map<String, dynamic> data){
    return LangData(
        name: data["name"] != null ? data["name"] : "",
        engName: data["engName"] != null ? data["engName"] : "",
        direction: data["direction"] != null ? data["direction"] == "ltr" ? TextDirection.ltr : TextDirection.rtl : TextDirection.ltr,
        locale: data["locale"] != null ? data["locale"] : "",
        data: {}
    );
  }
}

class StatusData {
  String id;
  List<StringData> name;
  int position;
  bool byCustomerApp;
  bool byProviderApp;
  bool cancel;
  String localFile = "";
  String serverPath = "";
  String assetName = "";

  StatusData({this.id = "", required this.name, this.position = 0,
    this.byCustomerApp = false, this.byProviderApp = false,
    this.localFile = "", this.serverPath = "", this.cancel = false,
    this.assetName = ""});

  factory StatusData.createEmpty(){
    return StatusData(name: []);
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name.map((i) => i.toJson()).toList(),
    'position': position,
    'byCustomerApp' : byCustomerApp,
    'byProviderApp' : byProviderApp,
    'cancel': cancel,
    'localFile': localFile,
    'serverPath': serverPath,
  };

  factory StatusData.fromJson(Map<String, dynamic> data){
    List<StringData> _name = [];
    if (data['name'] != null)
      List.from(data['name']).forEach((element){
        _name.add(StringData.fromJson(element));
      });
    return StatusData(
      id : (data["id"] != null) ? data["id"]: "",
      name: _name,
      position: (data["position"] != null) ? data["position"]: "",
      byCustomerApp : (data["byCustomerApp"] != null) ? data["byCustomerApp"]: false,
      byProviderApp : (data["byProviderApp"] != null) ? data["byProviderApp"]: false,
      cancel : (data["cancel"] != null) ? data["cancel"]: false,
      localFile : (data["localFile"] != null) ? data["localFile"]: false,
      serverPath : (data["serverPath"] != null) ? data["serverPath"]: false,
    );
  }
}

List<StatusData> statusesData = [];