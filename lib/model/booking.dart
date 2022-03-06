
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ondemandservice/model/service.dart';

import '../util.dart';
import 'model.dart';

class BookingData {
  String id;
  String status;
  List<StatusHistory> history;
  String servicemanid;
  //
  String customerId;
  String customer;
  String customerAvatar;
  String providerId;
  String providerPhone;
  List<StringData> provider;
  String providerAvatar;
  String serviceId;
  List<StringData> service;
  //
  List<StringData> priceName;
  double price;
  double discPrice;
  String priceUnit; // "hourly" or "fixed"
  int count;
  String couponId;
  String couponName;
  double discount;
  String discountType; // "percent" or "fixed"
  double tax;
  double taxAdmin;
  double total;
  //
  String paymentMethod;
  String comment;
  String address;
  bool anyTime;
  DateTime selectTime;
  DateTime time = DateTime.now();   // timestamp
  bool viewByAdmin;
  bool viewByProvider;
  bool rated;
  bool finished;
  List<AddonData> addon;

  BookingData({this.servicemanid="",this.id = "", this.status = "",
    this.customerId = "", this.customer = "", this.customerAvatar = "",
    this.providerId = "", required this.provider, this.serviceId = "", required this.service,
    this.price = 0, this.discPrice = 0, this.priceUnit = "fixed", this.count = 1, this.couponId = "",
    this.couponName = "", this.discount = 0, this.discountType = "fixed",
    this.tax = 0, this.total = 0,
    this.paymentMethod = "", this.comment = "", this.address = "", required this.time,
    this.anyTime = true, required this.selectTime, this.providerAvatar = "",
    this.providerPhone = "", required this.history, required this.priceName,
    this.viewByAdmin = false, this.viewByProvider = false, this.rated = false,
    this.taxAdmin = 0, this.finished = false, required this.addon
  });

  factory BookingData.createEmpty(){
    return BookingData(service: [], provider: [], time: DateTime.now(),
        selectTime: DateTime.now(), history: [], priceName: [], addon: []);
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'customerId': customerId,
    'customer' :  customer,
    'customerAvatar' :  customerAvatar,
    'providerId' : providerId,
    'provider' : provider.map((i) => i.toJson()).toList(),
    'providerAvatar' : providerAvatar,
    'serviceId': serviceId,
    'service': service.map((i) => i.toJson()).toList(),
    'price' : price,
    'discPrice': discPrice,
    'priceName': priceName.map((i) => i.toJson()).toList(),
    'priceUnit': priceUnit,
    'count': count,
    'couponId': couponId,
    'couponName': couponName,
    'discount': discount,
    'discountType': discountType,
    'tax' : tax,
    'taxAdmin': taxAdmin,
    'total': total,
    'paymentMethod': paymentMethod,
    'comment': comment,
    'address' : address,
    'anyTime': anyTime,
    'selectTime': selectTime.millisecondsSinceEpoch,
    'time': FieldValue.serverTimestamp(),
    'providerPhone': providerPhone,
    'history': history.map((i) => i.toJson()).toList(),
    'viewByAdmin' : viewByAdmin,
    'viewByProvider' : viewByProvider,
    'rated' : rated,
    'finished': finished,
    'addon': addon.map((i) => i.toJson()).toList(),
  };

  factory BookingData.fromJson(String id, Map<String, dynamic> data){
    List<StringData> _provider = [];
    if (data['provider'] != null)
      List.from(data['provider']).forEach((element){
        _provider.add(StringData.fromJson(element));
      });
    List<StringData> _service = [];
    if (data['service'] != null)
      List.from(data['service']).forEach((element){
        _service.add(StringData.fromJson(element));
      });
    List<StatusHistory> _history = [];
    if (data['history'] != null)
      List.from(data['history']).forEach((element){
        _history.add(StatusHistory.fromJson(element));
      });
    List<StringData> _priceName = [];
    if (data['priceName'] != null)
      List.from(data['priceName']).forEach((element){
        _priceName.add(StringData.fromJson(element));
      });
    List<AddonData> _addon = [];
    if (data['addon'] != null)
      List.from(data['addon']).forEach((element){
        _addon.add(AddonData.fromJson(element));
      });
    return BookingData(
      servicemanid: (data['servicemanid']!=null)?data['servicemanid'].toString():"",
      id: id,
      status: (data["status"] != null) ? data["status"] : "",
      customerId: (data["customerId"] != null) ? data["customerId"] : "",
      customer: (data["customer"] != null) ? data["customer"] : "",
      customerAvatar: (data["customerAvatar"] != null) ? data["customerAvatar"] : "",
      providerId: (data["providerId"] != null) ? data["providerId"] : "",
      providerPhone: (data["providerPhone"] != null) ? data["providerPhone"] : "",
      provider: _provider,
      providerAvatar: (data["providerAvatar"] != null) ? data["providerAvatar"] : "",
      serviceId: (data["serviceId"] != null) ? data["serviceId"] : "",
      service: _service,
      price: (data["price"] != null) ? toDouble(data["price"].toString()) : 0,
      discPrice: (data["discPrice"] != null) ? toDouble(data["discPrice"].toString()) : 0,
      priceUnit: (data["priceUnit"] != null) ? data["priceUnit"] : "",
      priceName: _priceName,
      count: (data["count"] != null) ? data["count"] : 1,
      couponId: (data["couponId"] != null) ? data["couponId"] : "",
      couponName: (data["couponName"] != null) ? data["couponName"] : "",
      discount: (data["discount"] != null) ? toDouble(data["discount"].toString()) : 0,
      discountType: (data["discountType"] != null) ? data["discountType"] : "",
      tax: (data["tax"] != null) ? toDouble(data["tax"].toString()) : 0,
      total: (data["total"] != null) ? toDouble(data["total"].toString()) : 0,
      paymentMethod: (data["paymentMethod"] != null) ? data["paymentMethod"] : "",
      comment: (data["comment"] != null) ? data["comment"] : "",
      address: (data["address"] != null) ? data["address"] : "",
      anyTime: (data["anyTime"] != null) ? data["anyTime"] : true,
      selectTime: (data["selectTime"] != null) ? DateTime.fromMillisecondsSinceEpoch(data["selectTime"]) : DateTime.now(),
      time: (data["time"] != null) ? data["time"].toDate().toLocal() : DateTime.now(),
      history: _history,
      viewByAdmin: (data["viewByAdmin"] != null) ? data["viewByAdmin"] : false,
      viewByProvider: (data["viewByProvider"] != null) ? data["viewByProvider"] : false,
      rated: (data["rated"] != null) ? data["rated"] : false,
      taxAdmin: (data["taxAdmin"] != null) ? toDouble(data["taxAdmin"].toString()) : 0,
      finished: (data["finished"] != null) ? data["finished"] : false,
      addon: _addon,
    );
  }

  StatusHistory getHistoryDate(String id){
    for (var item in history)
      if (item.statusId == id)
        return item;
    return StatusHistory.createEmpty();
  }

}

class StatusHistory{
  String statusId = "";
  DateTime time = DateTime.now();
  bool byCustomer;
  bool byProvider;
  bool byAdmin;
  String activateUserId;

  StatusHistory({this.statusId = "", required this.time, this.byCustomer = false,
    this.byProvider = false, this.byAdmin = false, this.activateUserId = ""
  });

  Map<String, dynamic> toJson() => {
    'statusId': statusId,
    'time': time,
    'byCustomer' : byCustomer,
    'byProvider' : byProvider,
    'byAdmin' : byAdmin,
    'activateUserId' : activateUserId,
  };

  factory StatusHistory.fromJson(Map<String, dynamic> data){
    return StatusHistory(
      statusId: (data["statusId"] != null) ? data["statusId"] : "",
      time: (data["time"] != null) ? (data["time"]).toDate().toLocal() : DateTime.now(),
      byCustomer: (data["byCustomer"] != null) ? data["byCustomer"] : false,
      byProvider: (data["byProvider"] != null) ? data["byProvider"] : false,
      byAdmin: (data["byAdmin"] != null) ? data["byAdmin"] : false,
      activateUserId: (data["activateUserId"] != null) ? data["activateUserId"] : "",
    );
  }

  factory StatusHistory.createEmpty(){
    return StatusHistory(time: DateTime.now());
  }
}
