import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ondemandservice/model/model.dart';
import 'package:ondemandservice/widgets/loader/loader7.dart';
import 'package:provider/provider.dart';
import '../../util.dart';
import '../../strings.dart';
import '../theme.dart';
import 'package:ondemandservice/widgets/appbars/appbar1.dart';
import 'package:ondemandservice/widgets/buttons/button2.dart';
import 'package:ondemandservice/widgets/clippath/clippath23.dart';
import 'package:ondemandservice/widgets/edit/edit42.dart';
import 'package:ondemandservice/widgets/edit/edit43.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  
  var windowWidth;
  var windowHeight;
  double windowSize = 0;
  var _editControllerName = TextEditingController();
  // var _editControllerEmail = TextEditingController();
  var _editControllerreferrel = TextEditingController();
  // var _editControllerPassword1 = TextEditingController();
  // var _editControllerPassword2 = TextEditingController();
  late MainModel _mainModel;
  bool referel= false;

  @override
  void initState() {
    _mainModel = Provider.of<MainModel>(context,listen:false);
    super.initState();
  }

  @override
  void dispose() {
    _editControllerName.dispose();
    // _editControllerEmail.dispose();
    // _editControllerPassword1.dispose();
    // _editControllerPassword2.dispose();
    _editControllerreferrel.dispose();
    super.dispose();
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
                      Text(strings.get(49), /// "Register",
                          style: theme.style25W800),
                      SizedBox(height: 10,),
                      Text(strings.get(50), /// "in less than a minute",
                          style: theme.style16W600Grey),
                    ],
                  ))),

                  Container(
                    margin: EdgeInsets.only(bottom: 20),
                    alignment: Alignment.bottomRight,
                      width: windowWidth*0.3,
                      height: windowWidth*0.3,
                      child: theme.registerLogoAsset ? Image.asset("assets/ondemands/ondemand5.png", fit: BoxFit.contain) :
                      CachedNetworkImage(
                          imageUrl: theme.registerLogo,
                          imageBuilder: (context, imageProvider) => Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                      ),)
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
                      child: edit42(strings.get(21), // "Name",
                          _editControllerName,
                          strings.get(22), // "Enter Name",
                          ),
                    ),

                    SizedBox(height: 20,),

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

                    // Container(
                    //   margin: EdgeInsets.only(left: 20, right: 20),
                    //   child: edit42(strings.get(23), // "Email",
                    //       _editControllerEmail,
                    //       strings.get(24), // "Enter Email",
                    //       ),
                    // ),

                    //SizedBox(height: 20,),

                    // Container(
                    //   margin: EdgeInsets.only(left: 20, right: 20),
                    //   child: Edit43(
                    //       text: strings.get(44), // "Password",
                    //       textStyle: theme.style14W600Grey,
                    //       controller: _editControllerPassword1,
                    //       hint: strings.get(45), // "Enter Password",
                    //       ),
                    // ),

                    //SizedBox(height: 20,),

                    // Container(
                    //   margin: EdgeInsets.only(left: 20, right: 20),
                    //   child: Edit43(
                    //       text: strings.get(51), // "Confirm Password",
                    //       textStyle: theme.style14W600Grey,
                    //       controller: _editControllerPassword2,
                    //       hint: strings.get(45), // "Enter Password",
                    //       ),
                    // ),

                   //SizedBox(height: 20,),


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
            //     "", context, () {_mainModel.goBack();}),

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

  _continue() async {

    if(referel!=false)
      if(_editControllerreferrel.text.isEmpty)
        return messageError(context, "Enter Agent Code"); /// Agent Code field check
    if (_editControllerName.text.isEmpty)
      return messageError(context, strings.get(135)); /// "Please Enter Email",
    // if (_editControllerPassword1.text.isEmpty || _editControllerPassword2.text.isEmpty)
    //   return messageError(context, strings.get(136)); /// "Please enter password",
    // if (_editControllerPassword1.text != _editControllerPassword2.text)
    //   return messageError(context, strings.get(140)); /// "Passwords are not equal",
    // if (!validateEmail(_editControllerEmail.text))
    //   return messageError(context, strings.get(139)); /// "Email are wrong",
    if(referel==true) {
      if (_editControllerreferrel.text.isEmpty)
        return messageError(context, "Enter Referrel Code");
    }

    _waits(true);
    var ret = await _mainModel.register(_editControllerName.text);
    var setagcode = await _mainModel.setagentcode(_editControllerreferrel.text);
    _waits(false);
    if (ret != null && setagcode!=null)
      return messageError(context, ret);
    await _mainModel.updateuserdetails();
    await _mainModel.checknewuser();
    _mainModel.route('home');
  }
}


