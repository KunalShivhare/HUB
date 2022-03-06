import 'dart:math';
import 'package:flutter/material.dart';
import 'package:ondemandservice/model/model.dart';
import 'package:ondemandservice/util.dart';
import 'package:ondemandservice/widgets/appbars/appbar1.dart';
import 'package:ondemandservice/widgets/edit/edit42.dart';
import 'package:provider/provider.dart';
import '../../strings.dart';
import '../theme.dart';
import 'package:ondemandservice/widgets/buttons/button2.dart';

class AddAddressScreen extends StatefulWidget {
  @override
  _AddAddressScreenState createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {

  var windowWidth;
  var windowHeight;
  double windowSize = 0;
  late MainModel _mainModel;
  late TextEditingController _addresscontroller;

  @override
  void initState() {
    _mainModel = Provider.of<MainModel>(context,listen:false);
    _addresscontroller=new TextEditingController();
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
                padding: EdgeInsets.only(top: 0, left: 20, right: 20),
                children: _children(),
              ),
            ),

            appbar1(Colors.transparent, (darkMode) ? Colors.white : Colors.black,
                strings.get(193), context, () {  /// Set Location
                    _mainModel.goBack();
            }),

          ]),
        ));
  }

  _children() {
    List<Widget> list = [];

    list.add(SizedBox(height: 100,));
    list.add(Container(
      width: windowWidth*0.5,
      height: windowWidth*0.5,
      child: Image.asset("assets/address2.png", fit: BoxFit.contain)
    ));
    list.add(SizedBox(height: 50,));

    list.add(edit42("Enter New Address", _addresscontroller,"House,Street..."));
    list.add(SizedBox(height: 10,));
    // list.add(Center(child: Text(strings.get(195), /// "By allowing location access, you can search for services and providers near your.",
    //     style: theme.style12W600Grey, textAlign: TextAlign.center,)));
    list.add(SizedBox(height: 50,));

    list.add(Container(
      alignment: Alignment.bottomCenter,
      margin: EdgeInsets.all(10),
      child: button2s("Add New Address", /// "Use currents location",
          theme.style16W800White, mainColor, theme.radius, () async {
            _addresscontroller.text.length>0? _mainModel.userAccount.addAddressByCurrentPosition(_addresscontroller.text):messageError(context, "Enter Address");
        }, true),
    ));
    // list.add(Container(
    //   alignment: Alignment.bottomCenter,
    //   margin: EdgeInsets.only(left: 10, right: 10),
    //   child: button2sg(strings.get(197), /// "Set from map"
    //       theme.style14W800MainColor, mainColor, theme.radius, (){
    //           _mainModel.route("address_add_map");
    //     }, true,
    //       darkMode ? Colors.black : Colors.white
    //   ),
    // ));
    list.add(SizedBox(height: 200,));
    return list;
  }


}

