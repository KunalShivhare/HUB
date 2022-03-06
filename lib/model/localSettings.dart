import 'dart:convert';
import 'dart:io';
import 'package:ondemandservice/model/booking.dart';
import 'package:ondemandservice/model/offers.dart';
import 'package:ondemandservice/ui/theme.dart';
import 'package:ondemandservice/model/service.dart';
import 'package:path_provider/path_provider.dart';
import '../util.dart';
import 'category.dart';
import 'model.dart';

getLocalSettings() async {
  dprint("getLocalSettings");
  try{
    var directory = await getApplicationDocumentsDirectory();
    var directoryPath = directory.path;
    var _file = File('$directoryPath/localSettings.json');
    if (await _file.exists()){
      final contents = await _file.readAsString();
      var data = json.decode(contents);
      dprint("getLocalSettings $data");
      localSettings = LocalSettings.fromJson(data);
      darkMode = localSettings.darkMode;
    }
  }catch(ex){
    print("exception getTheme $ex");
  }
}

LocalSettings localSettings = LocalSettings.createEmpty();

class LocalSettings{

  String locale = "";
  double mapLat = 0;
  double mapLng = 0;
  double mapZoom = 12;
  //List<String> address;
  //String currentAddress;
  String hint;
  bool darkMode = false;

  //
  // don't save
  //
  bool anyTime = true;
  bool scheduleTime = false;
  DateTime selectTime = DateTime.now();
  int count = 1;
  String couponCode = "";
  OfferData? coupon;
  PriceData price = PriceData.createEmpty();
  int paymentMethod = 1;
  clearBookData(){
    anyTime = true;
    scheduleTime = false;
    selectTime = DateTime.now();
    count = 1;
    price = PriceData.createEmpty();
    paymentMethod = 1;
    coupon = null;
    couponCode = "";
  }
  // String lastAddedId = "";
  // localSettings.lastAddedId = t.id;
  //
  // routes
  //
  String serviceScreenTag = "";
  String categoryScreenTag = "";
  CategoryData categoryData = CategoryData.createEmpty();



  // String chatName = "";
  // String chatId = "";
  // String chatSubName = "";
  // String chatLogo = "";
  BookingData jobInfo = BookingData.createEmpty();
  //
  //
  //
  double getCoupon(_mainModel){
    if (coupon == null)
      return 0;
    double total = price.getPrice()*count;
    if (coupon!.discountType == "percentage")
      return total*coupon!.discount/100;
    return coupon!.discount;
  }
  String getCouponString(MainModel _mainModel){
    return _mainModel.localAppSettings
        .getPriceString(getCoupon(_mainModel));
  }

  double _getTotal(MainModel _mainModel){
    var _price = count*price.getPrice();
    var _coupon = getCoupon(_mainModel);
    var _addon = getAddonsTotal(_mainModel);
    return _price-_coupon+_addon;
  }

  double getTax(MainModel _mainModel){
    return _getTotal(_mainModel)*_mainModel.currentService.tax/100;
  }
  String getTaxString(MainModel _mainModel){
    return _mainModel.localAppSettings.getPriceString(getTax(_mainModel));
  }
  double getTotal(MainModel _mainModel){                    //subscription change
    double _total = _getTotal(_mainModel);
    if(_mainModel.getSubvalue()==false)
    return _total + getTax(_mainModel) - getCoupon(_mainModel);
    else {
      if(_mainModel.getSubtypevalue()=="Platinum") {
        print("Platinum");
        return 0.0;
      }

      if(_mainModel.getSubtypevalue()=="Silver" && _mainModel.currentService.category.any((element){return (_mainModel.getCategoryNameById(element)=="Electronics"?true:false);})) {
        print("Silver");
        return 0.0;
      }

      if(_mainModel.getSubtypevalue()=="Gold" && (_mainModel.currentService.category.any((element){return (_mainModel.getCategoryNameById(element)=="Electrical"?true:false);})
       || _mainModel.currentService.category.any((element){return (_mainModel.getCategoryNameById(element)=="Carpenter"?true:false);})
          || _mainModel.currentService.category.any((element){return (_mainModel.getCategoryNameById(element)=="Plumber"?true:false);}))
      ) {
        print("Gold");
        return 0.0;
      }

      // if(_mainModel.currentService.category.any((element) { return (_mainModel.getCategoryNameById(element)=="Electronics"?true:false);})) {
      //   if (_mainModel.getSubtypevalue() == "Gold")
      //     return 0.0;
      //   else if (_mainModel.getSubtypevalue() == "Platinum")
      //     return _total + getTax(_mainModel) - getCoupon(_mainModel);
      //   else
      //     return 0.0;
      // }
      // else
         return _total + getTax(_mainModel) - getCoupon(_mainModel);
    }
  }
  String getTotalString(MainModel _mainModel){                //subscription change
    //print(_mainModel.getSubtypevalue());
    if(_mainModel.getSubvalue()==false)
    return _mainModel.localAppSettings.getPriceString(getTotal(_mainModel));
    else{
      if(_mainModel.getSubtypevalue()=="Platinum") {
        print("Platinum");
        return "0";
      }

      if(_mainModel.getSubtypevalue()=="Silver" && _mainModel.currentService.category.any((element){return (_mainModel.getCategoryNameById(element)=="Electronics"?true:false);})) {
        print("Silver");
        return "0";
      }

      if(_mainModel.getSubtypevalue()=="Gold" && (_mainModel.currentService.category.any((element){return (_mainModel.getCategoryNameById(element)=="Electrical"?true:false);})
          || _mainModel.currentService.category.any((element){return (_mainModel.getCategoryNameById(element)=="Carpenter"?true:false);})
          || _mainModel.currentService.category.any((element){return (_mainModel.getCategoryNameById(element)=="Plumber"?true:false);}))
      ) {
        print("Gold");
        return "0";
      }

      // if(_mainModel.currentService.category.any((element) { return (_mainModel.getCategoryNameById(element)=="Electronics"?true:false);})) {
      //   if (_mainModel.getSubtypevalue() == "Gold")
      //     return "0";
      //   else if (_mainModel.getSubtypevalue() == "Platinum")
      //     return _mainModel.localAppSettings.getPriceString(getTotal(_mainModel));
      //   else
      //     return "0";
      // }
      return _mainModel.localAppSettings.getPriceString(getTotal(_mainModel));
    }
  }
  double getAddonsTotal(MainModel _mainModel){
    double total = 0;
    for (var item in _mainModel.currentService.addon)
      if (item.selected)
        total += (item.needCount*item.price);
    return total;
  }

  //
  //
  //

  LocalSettings({
    this.locale = "",
    this.mapLat = 0,
    this.mapLng = 0,
    this.mapZoom = 12,
    //required this.address,
    //this.currentAddress = "",
    this.hint = "",
    this.darkMode = false
  });

  Map<String, dynamic> toJson() => {
    'locale' : locale,
    'mapLat' : mapLat,
    'mapLng' : mapLng,
    'mapZoom' : mapZoom,
    // 'address' : address,
    // 'currentAddress' : currentAddress,
    'hint' : hint,
    'darkMode' : darkMode,
  };

  factory LocalSettings.createEmpty(){
    return LocalSettings();
  }

  factory LocalSettings.fromJson(Map<String, dynamic> data){
    List<String> _address = [];
    if (data['address'] != null)
      for (dynamic key in data['address'])
        _address.add(key.toString());
    return LocalSettings(
      locale : (data["locale"] != null) ? data["locale"]: "",
      mapLat : (data["mapLat"] != null) ? toDouble(data["mapLat"].toString()): 0,
      mapLng : (data["mapLng"] != null) ? toDouble(data["mapLng"].toString()): 0,
      mapZoom : (data["mapZoom"] != null) ? toDouble(data["mapZoom"].toString()): 0,
      // address: _address,
      // currentAddress : (data["currentAddress"] != null) ? data["currentAddress"]: "",
      hint : (data["hint"] != null) ? data["hint"]: "",
      darkMode: (data["darkMode"] != null) ? data["darkMode"]: false,
    );
  }
  //
  //
  //
  setLocal(String value){
    locale = value;
    dprint("LocalSettings setLocal $value");
    _save();
  }
  setMap(double lat, double lng, double zoom){
    mapLat = lat;
    mapLng = lng;
    mapZoom = zoom;
    dprint("LocalSettings setMap");
    _save();
  }

  // addAddress(String _address){
  //   address.add(_address);
  //   dprint("LocalSettings add address new=$_address all=$address");
  //   _save();
  // }
  //
  // setCurrentAddress(String val){
  //   currentAddress = val;
  //   dprint("LocalSettings setCurrentAddress _cur=$val");
  //   _save();
  // }

  setHint(String val){
    hint = val;
    dprint("LocalSettings setHint val=$val");
    _save();
  }

  setDarkMode(bool val){
    darkMode = val;
    dprint("LocalSettings setDarkMode val=$val");
    _save();
  }

  _save() async {
    var directory = await getApplicationDocumentsDirectory();
    var directoryPath = directory.path;
    await File('$directoryPath/localSettings.json').writeAsString(json.encode(this.toJson()));
  }
}