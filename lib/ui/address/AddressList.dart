import 'dart:math';
import 'package:flutter/material.dart';
import 'package:ondemandservice/model/model.dart';
import 'package:ondemandservice/model/user.dart';
import 'package:ondemandservice/widgets/appbars/appbar1.dart';
import 'package:ondemandservice/widgets/buttons/button197a.dart';
import 'package:provider/provider.dart';
import '../../strings.dart';
import '../../util.dart';
import '../theme.dart';
import 'package:ondemandservice/widgets/buttons/button2.dart';

class AddressListScreen extends StatefulWidget {
  @override
  _AddressListScreenState createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {

  var windowWidth;
  var windowHeight;
  double windowSize = 0;
  bool subs=false;
  late MainModel _mainModel;

  @override
  void initState() {
    _mainModel = Provider.of<MainModel>(context,listen:false);
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(new FocusNode());
    });
    subs=_mainModel.getSubvalue();setState(() {

    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    windowSize = min(windowWidth, windowHeight);

    return Scaffold(
        backgroundColor: (darkMode) ? blackColorTitleBkg : colorBackground,
        body: Directionality(
        textDirection: strings.direction,
        child: Stack(
          children: [

            Container(
              child: ListView(
                padding: EdgeInsets.only(top: 0, left: 10, right: 10),
                children: _children(),
              ),
            ),

            appbar1(Colors.transparent, (darkMode) ? Colors.white : Colors.black,
                strings.get(188), context, () {_mainModel.goBack();}), /// My Address

            !_mainModel.getSubvalue()?
              Container(
              alignment: Alignment.bottomCenter,
              margin: EdgeInsets.all(10),
              child: button2s(strings.get(117), /// "Add address",
              theme.style16W800White, mainColor, theme.radius, (){
              _mainModel.route("address_add");
              }, true),
              )
            : _mainModel.userAddress.length<1 ? Container(
                alignment: Alignment.bottomCenter,
                margin: EdgeInsets.all(10),
                child: button2s(strings.get(117), /// "Add address",
                theme.style16W800White, mainColor, theme.radius, (){
                _mainModel.route("address_add");
                }, true),
                ):Container(),
          ]),
        ));
  }

  _children() {
    List<Widget> list = [];

    list.add(SizedBox(height: MediaQuery.of(context).padding.top+50,));

    var _count = 0;
    list.add(SizedBox(height: 10,));
    var _address = _mainModel.userAccount.getCurrentAddress();
    if (_address.id.isNotEmpty){
      list.add(Text(strings.get(214) + ":", style: theme.style12W600Grey,)); /// "Current address",
      list.add(SizedBox(height: 10,));
      list.add(_item(_address, false));
      list.add(SizedBox(height: 10,));
    }

    bool _first = true;
    for (var item in _mainModel.userAddress) {
      if (item == _address)
        continue;
      if (_first){
        list.add(SizedBox(height: 10,));
        list.add(Text(strings.get(215) + ":", style: theme.style12W600Grey,)); /// "Other addresses",
        list.add(SizedBox(height: 10,));
        _first = false;
      }
      list.add(_item(item, true));
      list.add(SizedBox(height: 10,));
      _count++;
    }

    if (_count == 0){
        list.add(SizedBox(height: 100,));
        list.add(Container(
            width: windowWidth*0.5,
            height: windowWidth*0.5,
            child: Image.asset("assets/nofound.png", fit: BoxFit.contain)
        ));
        list.add(SizedBox(height: 50,));
        list.add(Center(child: Text(strings.get(189), /// "Address not found",
            style: theme.style14W800)));
    }

    list.add(SizedBox(height: 200,));
    return list;
  }

  _item(AddressData item, bool upIcon){
    return Stack(
        children: [
          Positioned.fill(child: Container(
            margin: EdgeInsets.only(left: 10, right: 10),
            alignment: Alignment.centerRight,
            child: Icon(Icons.delete, color:Colors.red, size: 30,),
          )),
          Dismissible(key: Key(item.id),
              onDismissed: (DismissDirection _direction){
                _delete(item);
              },
              confirmDismiss: (DismissDirection _direction) async {
                if (_direction == DismissDirection.startToEnd)
                  return false;
                return true;
              },
              child:
              Button197a(
                  item: item,
                  upIcon: upIcon,
                pressButtonDelete: (){
                  subs?(){}:_delete(item);
                },
                pressButton: (){
                  _mainModel.addressData = item;
                  //_mainModel.route("address_details");
                },
                pressSetCurrent: (){
                  _mainModel.userAccount.setCurrentAddress(item.id);
                  _redraw();
                }
              )
          )
        ]);
  }

  _delete(AddressData item) async {
    var ret = await _mainModel.userAccount.deleteLocation(item);
    if (ret != null)
      messageError(context, ret);
    _redraw();
  }

  _redraw(){
    if (mounted)
      setState(() {
      });
  }

}

