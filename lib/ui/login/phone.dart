import 'dart:math';
import 'package:flutter/material.dart';
import 'package:ondemandservice/model/model.dart';
import 'package:ondemandservice/widgets/loader/loader7.dart';
import 'package:provider/provider.dart';
import '../../strings.dart';
import '../../util.dart';
import '../theme.dart';
import 'package:ondemandservice/widgets/appbars/appbar1.dart';
import 'package:ondemandservice/widgets/buttons/button2.dart';
import 'package:ondemandservice/widgets/clippath/clippath23.dart';
import 'package:ondemandservice/widgets/edit/edit42.dart';

class PhoneScreen extends StatefulWidget {
  @override
  _PhoneScreenState createState() => _PhoneScreenState();
}

class _PhoneScreenState extends State<PhoneScreen> {
  
  var windowWidth;
  var windowHeight;
  double windowSize = 0;
  var _editControllerPhone = TextEditingController();
  var _editControllerreferrel = TextEditingController();
  late MainModel _mainModel;
  bool referel=false;
  @override
  void initState() {
    _mainModel = Provider.of<MainModel>(context,listen:false);
    super.initState();
  }

  @override
  void dispose() {
    _editControllerPhone.dispose();
    _editControllerreferrel.dispose();
    super.dispose();
  }

  @override
  void deactivate() {
    _out();
    super.deactivate();
  }

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
                      )),
                ],


              ),
            )),

            Container(
              margin: EdgeInsets.only(top: windowHeight*0.3),
              height: windowHeight*0.9,
              color: (darkMode) ? Colors.black : Colors.white,
              child: SingleChildScrollView(
                child: Column(
                  children: [

                    SizedBox(height: 20,),

                    Container(
                      margin: EdgeInsets.only(left: 20, right: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(_mainModel.localAppSettings.otpPrefix,
                              style: theme.style18W800),
                          SizedBox(width: 10,),
                          Expanded(child: edit42Phone(strings.get(25), // "Phone number",
                              theme.style14W600Grey, _editControllerPhone,
                              strings.get(26), // "Enter your Phone number",
                              theme.style15W400, Colors.grey, true)),
                        ],
                      )
                    ),

                    SizedBox(height: 50,),

                    Center(
                      child: Text(strings.get(53), // "We'll sent verification code.",
                          style: theme.style15W400),
                    ),

                    SizedBox(height: 50,),
                    Container(
                      margin: EdgeInsets.only(left: 20, right: 20),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children:[
                            Text("By Agent?"),
                            Checkbox(value: referel, onChanged: (val){
                              setState(() {
                                referel=!referel;
                              });
                            }),
                          ]),
                    ),
                    SizedBox(height: 20,),

                    referel? Container(
                      margin: EdgeInsets.only(left: 20, right: 20),
                      child: edit42("Agent Code", // "Agent code",
                        _editControllerreferrel,
                        "Agent Code", // "Enter Email",
                      ),
                    ):Container(),
                    Container(
                      margin: EdgeInsets.all(20),
                      child: button2s(strings.get(46), // "CONTINUE",
                          theme.style16W800White, mainColor, 50, (){_continue();}, true),
                    ),

                  ],
                ),
              ),
            ),

            // appbar1(Colors.transparent, (darkMode) ? Colors.white : Colors.black,
            //     "", context, () {_out(); _mainModel.goBack();}),                   //testchange

            if (_wait)
              Center(child: Container(child: Loader7(color: mainColor,))),

          ],
        )

    ));
  }

  bool _wait = false;
  _waits(bool value){
    _wait = value;
    _redraw();
  }
  _redraw(){
    if (mounted)
      setState(() {
      });
  }

  bool _continuePress = false;

  _continue() async {
    if (_editControllerPhone.text.isEmpty)
      return messageError(context, strings.get(26)); /// "Enter your phone number",

    if(referel!=false)
      if(_editControllerreferrel.text.isEmpty)
        return messageError(context, "Enter Agent Code"); /// Agent Code field check

    _continuePress = true;

    var login = (){
      _mainModel.goBack();
    };

    var _goToCode = (){
      _mainModel.route("otp");
    };


    // _waits(true);
    // // var ret = await _mainModel.userAccount.sendOTPCode(_editControllerPhone.text, context, login, _goToCode);
    // // var setagcode = await _mainModel.setagentcode(_editControllerreferrel.text);
    // _waits(false);
    // if (ret != null && setagcode != null) {
    //   messageError(context, ret);
    //   messageError(context, setagcode);
    // }

  }
}


