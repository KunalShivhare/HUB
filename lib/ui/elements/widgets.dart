import 'package:flutter/material.dart';
import 'package:ondemandservice/model/model.dart';
import 'package:ondemandservice/model/service.dart';
import 'package:ondemandservice/ui/theme.dart';
import '../../strings.dart';

getPriceText(PriceData item, List<Widget> list2, MainModel _mainModel){
  if (item.discPrice == 0)
    list2.add(Column(
      children: [
        Text(_mainModel.localAppSettings.getPriceString(item.price), style: theme.style20W800Green),
        Text((item.priceUnit == "fixed") ? strings.get(130) : strings.get(131), style: theme.style12W800), /// "fixed", - "hourly",
      ],));
  else{
    list2.add(Column(
      children: [
        Text(_mainModel.localAppSettings.getPriceString(item.discPrice), style: theme.style20W800Red),
        Text((item.priceUnit == "fixed") ? strings.get(130) : strings.get(131), style: theme.style12W800), /// "fixed", - "hourly",
      ],
    ));
    list2.add(SizedBox(width: 5,));
    list2.add(Text(_mainModel.localAppSettings.getPriceString(item.price), style: theme.style16W400U),);
  }
}

