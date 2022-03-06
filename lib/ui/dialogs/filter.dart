import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ondemandservice/model/model.dart';
import 'package:ondemandservice/ui/theme.dart';
import 'package:ondemandservice/util.dart';
import 'package:ondemandservice/widgets/buttons/button134.dart';
import 'package:ondemandservice/widgets/buttons/button2.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

import '../../strings.dart';

int _ascDesc = 0;
SfRangeValues _price = SfRangeValues(100, 1000);
bool applyFilter = false;

double getFilterMinPrice(){
  return _price.start;
}

double getFilterMaxPrice(){
  return _price.end;
}

setPriceRange(MainModel _mainModel){
  if (!applyFilter){
    _price = SfRangeValues(_mainModel.filter.getMinPrice(), _mainModel.filter.getMaxPrice());
    _ascDesc = 0;
  }
}

getBodyFilterDialog(Function() _redraw, Function() _close, MainModel _mainModel){
    double _min = _mainModel.filter.getMinPrice();
    double _max = _mainModel.filter.getMaxPrice();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(child: Text(strings.get(181), /// "Filter",
            textAlign: TextAlign.center, style: theme.style14W800)),
        SizedBox(height: 10,),
        Text(strings.get(182), /// "Sort by",
            textAlign: TextAlign.start, style: theme.style13W800),
        SizedBox(height: 5,),
        Row(
          children: [
            Expanded(child: button2s(strings.get(183), /// "Ascending (A-Z)",
                _ascDesc == 1 ? theme.style14W800W : theme.style14W800, _ascDesc == 1 ? mainColor : darkMode ? Colors.grey
                    : Colors.grey.withAlpha(20), 10,
                    (){
                  _ascDesc = 1;
                  _redraw();
                }, true)),
            SizedBox(width: 10,),
            Expanded(child: button2s(strings.get(184), /// "Descending (Z-A)",
                _ascDesc == 2 ? theme.style14W800W : theme.style14W800, _ascDesc == 2 ? mainColor : darkMode ? Colors.grey
                    : Colors.grey.withAlpha(20), 10,
                    (){
                  _ascDesc = 2;
                  _redraw();
                }, true)),
          ],
        ),
        SizedBox(height: 5,),
        Row(
          children: [
            Expanded(child: button2s(strings.get(222), /// "Nearby you",
                _ascDesc == 3 ? theme.style14W800W : theme.style14W800, _ascDesc == 3 ? mainColor : darkMode ? Colors.grey
                    : Colors.grey.withAlpha(20), 10,
                    (){
                  _ascDesc = 3;
                  _redraw();
                }, true)),
            SizedBox(width: 10,),
            Expanded(child: button2s(strings.get(223), /// "Far",
                _ascDesc == 4 ? theme.style14W800W : theme.style14W800, _ascDesc == 4 ? mainColor : darkMode ? Colors.grey
                    : Colors.grey.withAlpha(20), 10,
                    (){
                  _ascDesc = 4;
                  _redraw();
                }, true)),
          ],
        ),
        SizedBox(height: 10,),
        Text(strings.get(185), /// "Price",
            textAlign: TextAlign.start, style: theme.style13W800),
        SfRangeSlider(
          activeColor: mainColor,
          inactiveColor: mainColor.withAlpha(100),
          tickShape: SfTickShape(),
          min: _min,
          max: _max,
          enableTooltip: true,
          interval: (_max-_min)/4,
          showTicks: true,
          showDividers: true,
          enableIntervalSelection: true,
          showLabels: true,
          numberFormat: NumberFormat("\₹"),
          onChanged: (SfRangeValues newValue) {
            _price = newValue;
            _redraw();
          },
          values: _price,
        ),
        SizedBox(height: 40,),
        Row(
          children: [
            Expanded(child: button134(strings.get(186), (){
              applyFilter = false;
              _close();
            }, true, theme.style14W800)), /// "Reset Filter",
            SizedBox(width: 10,),
            Expanded(child: button2s(strings.get(187), /// "Apply Filter",
              theme.style14W800W, mainColor, 10,
                  (){
                    _mainModel.serviceSearch = [];
                    for (var item in _mainModel.service){
                        if (getFilterMinPrice() > _mainModel.localAppSettings.getServiceMinPriceDouble(item))
                          continue;
                        if (getFilterMaxPrice() < _mainModel.localAppSettings.getServiceMinPriceDouble(item))
                          continue;
                      _mainModel.serviceSearch.add(item);
                    }
                    if (_ascDesc == 1)
                      _mainModel.serviceSearch.sort((a, b) => getTextByLocale(a.name).compareTo(getTextByLocale(b.name)));
                    if (_ascDesc == 2)
                      _mainModel.serviceSearch.sort((a, b) => getTextByLocale(b.name).compareTo(getTextByLocale(a.name)));
                    if (_ascDesc == 3)
                      _mainModel.serviceSearch.sort((a, b) => _mainModel.getDistanceByProviderId(a.providers[0])
                          .compareTo(_mainModel.getDistanceByProviderId(b.providers[0])));
                    if (_ascDesc == 4)
                      _mainModel.serviceSearch.sort((a, b) => _mainModel.getDistanceByProviderId(b.providers[0])
                          .compareTo(_mainModel.getDistanceByProviderId(a.providers[0])));

                    applyFilter = true;
                    _close();
              }, true))
          ],
        ),
      ],
    );
}
