
import 'package:ondemandservice/util.dart';

import 'model.dart';

class OfferData {
  String id;
  String code;
  List<StringData> desc;
  double discount;
  String discountType; // "percent" or "fixed"
  bool visible;
  List<String> services; // Id
  List<String> providers; // Id
  List<String> category; // Id
  DateTime expired;

  OfferData(this.id, this.code, {this.visible = true, required this.desc, this.discountType = "fixed",
    required this.services, required this.providers, required this.category, this.discount = 0, required this.expired});

  factory OfferData.createEmpty(){
    return OfferData("", "", services: [], providers: [], category: [], expired: DateTime.now(), desc: []);
  }

  Map<String, dynamic> toJson() => {
    'code': code,
    'desc': desc.map((i) => i.toJson()).toList(),
    'discount': discount,
    'discountType': discountType,
    'visible': visible,
    'services': services,
    'providers': providers,
    'category': category,
    'expired': expired.millisecondsSinceEpoch,
  };

  factory OfferData.fromJson(String id, Map<String, dynamic> data){
    List<StringData> _desc = [];
    if (data['desc'] != null)
      List.from(data['desc']).forEach((element){
        _desc.add(StringData.fromJson(element));
      });
    List<String> _services = [];
    if (data['services'] != null)
      List.from(data['services']).forEach((element){
        _services.add(element);
      });
    List<String> _providers = [];
    if (data['providers'] != null)
      List.from(data['providers']).forEach((element){
        _providers.add(element);
      });
    List<String> _category = [];
    if (data['category'] != null)
      List.from(data['category']).forEach((element){
        _category.add(element);
      });
    return OfferData(
      id,
      (data["code"] != null) ? data["code"] : "",
      desc: _desc,
      discount: (data["discount"] != null) ? toDouble(data["discount"].toString()) : 0,
      discountType: (data["discountType"] != null) ? data["discountType"] : "",
      visible: (data["visible"] != null) ? data["visible"] : true,
      services: _services,
      providers: _providers,
      category: _category,
      expired: (data["expired"] != null) ? DateTime.fromMillisecondsSinceEpoch(data["expired"]) : DateTime.now(),
    );
  }

}