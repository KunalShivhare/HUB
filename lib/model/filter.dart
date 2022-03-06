import 'package:ondemandservice/model/service.dart';
import 'model.dart';

class MainDataFilter  {
  final MainModel parent;

  MainDataFilter({required this.parent});

  double getMinPrice(){
    double _min = double.infinity;
    for (var item in parent.service) {
      var _price = getPrice(item.price);
      if (_price < _min)
        _min = _price;
    }
    if (_min == double.infinity)
      _min = 0;
    return _min;
  }

  double getMaxPrice(){
    double _max = 0;
    for (var item in parent.service) {
      var _price = getPrice(item.price);
      if (_price > _max)
        _max = _price;
    }
    return _max;
  }

  double getPrice(List<PriceData> _currentPrice){
    double _price = double.maxFinite;
    for (var item in _currentPrice) {
      if (item.discPrice != 0){
        if (item.discPrice < _price)
          _price = item.discPrice;
      }else
        if (item.price < _price)
          _price = item.price;
    }
    if (_price == double.maxFinite)
      _price = 0;
    return _price;
  }

}