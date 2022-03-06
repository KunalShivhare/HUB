import 'dart:math';
import 'package:flutter/material.dart';
import 'package:ondemandservice/model/model.dart';
import 'package:ondemandservice/ui/theme.dart';
import 'package:provider/provider.dart';
import '../../strings.dart';
import 'package:ondemandservice/widgets/appbars/appbar1.dart';
import 'package:ondemandservice/widgets/buttons/button2.dart';
import 'package:ondemandservice/widgets/clippath/clippath23.dart';
import 'package:ondemandservice/widgets/edit/edit42.dart';

import '../../util.dart';

class OTPScreen extends StatefulWidget {
  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {

  var windowWidth;
  var windowHeight;
  double windowSize = 0;
  var _editControllerCode = TextEditingController();
  late MainModel _mainModel;

  @override
  void initState() {
    _mainModel = Provider.of<MainModel>(context,listen:false);
    super.initState();
  }

  @override
  void dispose() {
    _editControllerCode.dispose();
    super.dispose();
  }

  @override
  void deactivate() {
    _out();
    super.deactivate();
  }

  bool _continuePress = false;

  _out() {
    if (!_continuePress)
      _mainModel.logout();
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    windowSize = min(windowWidth, windowHeight);
    return Scaffold(
        backgroundColor: (darkMode) ? Colors.black : Colors.white,
        body: Directionality(
        textDirection: strings.direction,
        child: Stack(
          children: <Widget>[

        ClipPath(
          clipper: ClipPathClass23(20),
          child: Container(
            color: (darkMode) ? blackColorTitleBkg : colorBackground,
            width: windowWidth,
              height: windowHeight*0.3,
              child: Row(
                children: [
                  Expanded(
                      child: Container(
                        margin: EdgeInsets.only(left: 20, right: 20),
                    child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(strings.get(52), // "Verification",
                          style: theme.style25W800),
                      SizedBox(height: 5,),
                      Text(strings.get(50), // "in less than a minute",
                          style: theme.style16W600Grey),
                    ],
                  ))),

                  Container(
                    margin: EdgeInsets.only(bottom: 20),
                    alignment: Alignment.bottomRight,
                      width: windowWidth*0.3,
                      child: Image.asset("assets/ondemands/ondemand4.png",
                          fit: BoxFit.contain
                      ))
                ],


              ),
            )),

            Container(
              margin: EdgeInsets.only(top: windowHeight*0.4),
              height: windowHeight*0.6,
              color: (darkMode) ? Colors.black : Colors.white,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Center(
                      child: Text(strings.get(54), // "We've sent 6 digit verification code.",
                          style: theme.style15W400),
                    ),

                    SizedBox(height: 50,),

                    Container(
                      margin: EdgeInsets.only(left: 20, right: 20),
                      child: edit42Numbers(strings.get(55), // "Enter code",
                          theme.style14W600Grey, _editControllerCode,
                          strings.get(56), // "Enter 6 digits code",
                          theme.style15W400, Colors.grey),
                    ),

                    SizedBox(height: 20,),

                    Container(
                      margin: EdgeInsets.all(20),
                      child: button2s(strings.get(46), // "CONTINUE",
                          theme.style16W800White, mainColor, 50, (){_continue();}, true),
                    ),

                  ],
                ),
              ),
            ),

             appbar1(Colors.transparent, (darkMode) ? Colors.white : Colors.black,
                 "", context, () {_out(); _mainModel.goBack(); })

          ],
        )

    ));
  }

  _continue() async {
    var ret = await _mainModel.userAccount.otp(_editControllerCode.text);
    if (ret != null)
      return messageError(context, ret);

    _continuePress = true;

    _mainModel.route("home");
  }
}



