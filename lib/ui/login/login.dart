import 'dart:io';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ondemandservice/model/model.dart';
//import 'package:ondemandservice/widgets/appbars/appbar1.dart';
import 'package:ondemandservice/widgets/bottom/buttonIOS.dart';
import 'package:ondemandservice/widgets/buttons/button134.dart';
import 'package:ondemandservice/widgets/loader/loader7.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../util.dart';
import '../../strings.dart';
import '../theme.dart';
import 'package:ondemandservice/widgets/buttons/button195.dart';
import 'package:ondemandservice/widgets/buttons/button196.dart';
import 'package:ondemandservice/widgets/buttons/button2.dart';
import 'package:ondemandservice/widgets/clippath/clippath23.dart';
import 'package:ondemandservice/widgets/edit/edit42.dart';
import 'package:ondemandservice/widgets/edit/edit43.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  bool otpsent=false;
  var windowWidth;
  var windowHeight;
  double windowSize = 0;
  var _editControllerPhone = TextEditingController();
  var _editControllerCode = TextEditingController();
  //var _editControllerEmail = TextEditingController();
  // var _editControllerPassword = TextEditingController();
  late MainModel _mainModel;

  @override
  void initState() {
    _mainModel = Provider.of<MainModel>(context,listen:false);
    super.initState();
  }

  @override
  void dispose() {
    _editControllerCode.dispose();
    _editControllerPhone.dispose();
    // _editControllerPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    windowSize = min(windowWidth, windowHeight);
    return otpsent ? Scaffold(
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

              ],
            )

        ))
      :  Scaffold(
      backgroundColor: (darkMode) ? Colors.black : Colors.white,
        body: WillPopScope(
          onWillPop: ()async =>false,
          child: Directionality(
          textDirection: strings.direction,
          child: Stack(
            children: <Widget>[

              ListView(
                children: [

                  ClipPath(
                      clipper: ClipPathClass23(20),
                      child: Container(
                        color: (darkMode) ? blackColorTitleBkg : colorBackground,
                        width: windowWidth,
                        height: windowHeight/2.1,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(height: windowHeight*0.1,),
                            Container(
                              width: windowWidth*0.3,
                              height: windowWidth*0.3,
                              child: theme.loginLogoAsset ? Image.asset("assets/ondemands/ondemand1.png", fit: BoxFit.contain) :
                              CachedNetworkImage(
                                  imageUrl: theme.loginLogo,
                                  imageBuilder: (context, imageProvider) => Container(
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  )
                              ),
                            ),
                            SizedBox(height: 20,),
                            Text("HUB CARE", // "HANDYMAN",
                                style: theme.style16W800),
                            SizedBox(height: 5,),
                            // Text(strings.get(1), // "SERVICE",
                            //     style: theme.style10W600Grey),
                            // SizedBox(height: 20,),
                            Expanded(child: Container(
                                width: windowWidth,
                                child: theme.loginImageAsset ? Image.asset("assets/ondemands/ondemand2.png", fit: BoxFit.cover) :
                                CachedNetworkImage(
                                    imageUrl: theme.loginImage,
                                    imageBuilder: (context, imageProvider) => Container(
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    )
                                ),
                            )
                            )
                          ],
                        ),
                      )),

                  Container(
                    height: windowHeight*0.5,
                    color: (darkMode) ? Colors.black : Colors.white,
                    child: SingleChildScrollView(
                      child: Center(
                        child: Column(
                          children: [
                            Center(
                              child: Text(strings.get(43), // "Sign in now",
                                style: theme.style16W800,
                              ),
                            ),

                            SizedBox(height: 10,),

                            Container(
                              margin: EdgeInsets.only(left: 20, right: 20),
                              child:edit42Phone(strings.get(25), // "Phone number",
                                  theme.style14W600Grey, _editControllerPhone,
                                  strings.get(26), // "Enter your Phone number",
                                  theme.style15W400, Colors.grey, true)

                              // edit42(strings.get(23), /// "Email",
                              //     _editControllerEmail,
                              //     strings.get(24), // "Enter your Email",
                              //     type: TextInputType.emailAddress
                              //     ),
                            ),

                            SizedBox(height: 20,),

                            // Container(
                            //   margin: EdgeInsets.only(left: 20, right: 20),
                            //   child: Edit43(
                            //       text: strings.get(44), // "Password",
                            //       textStyle: theme.style14W600Grey,
                            //       controller: _editControllerPassword,
                            //       hint: strings.get(45), // "Enter your Password",
                            //       ),
                            // ),

                            //SizedBox(height: 20,),

                            Container(
                              margin: EdgeInsets.all(20),
                              child: button2s(strings.get(46), /// "CONTINUE",
                                  theme.style16W800White, mainColor, 50, _login, true),
                            ),

                            //SizedBox(height: 5,),
                            // button134(strings.get(227), /// "Forgot password?",
                            //         (){
                            //       _mainModel.route("forgot");
                            //     }, true, theme.style14W400),
                            //SizedBox(height: 5,),

                            // SizedBox(height: 20,),

                            // Container(
                            //   margin: EdgeInsets.all(20),
                            //   child: button2s(strings.get(47), // "REGISTER",
                            //       theme.style16W800White, mainColor, 50, (){
                            //         _mainModel.route("register");
                            //     }, true),
                            // ),

                            // Center(
                            //   child: Text(strings.get(48), // "or continue with",
                            //       style: theme.style14W600Grey),
                            // ),

                            SizedBox(height: 10,),
                            // if (Platform.isIOS)
                            //   buttonIOS("assets/apple.png", _appleLogin, windowWidth * 0.9, "Sign in with Apple"),
                            // SizedBox(height: 10,),

                            // Container(
                            //     alignment: Alignment.bottomCenter,
                            //     child: Row(
                            //       mainAxisAlignment: MainAxisAlignment.spaceAround,
                            //       children: [
                            //         Flexible(child: button195a("Facebook", theme.style16W800White, mainColor, _facebookLogin, true)),
                            //         SizedBox(width: 1,),
                            //         Flexible(child: button196a("Google", theme.style16W800White, mainColor, _googleLogin, true)),
                            //       ],
                            //     )
                            // )
                          ],
                        ),
                      ),
                    ),
                  ),

                ],
              ),


              // appbar1(Colors.transparent, (darkMode) ? Colors.white : Colors.black,
              //     "", context, () {_mainModel.goBack();}),

              if (_wait)
                Center(child: Container(child: Loader7(color: mainColor,))),

            ],
          )

    ),
        ));
  }

  _continue() async {
    var ret = await _mainModel.userAccount.otp(_editControllerCode.text);
    if (ret != null)
      return messageError(context, ret);

    _mainModel.route("home");
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

  _login() async {
    if (_editControllerPhone.text.isEmpty)
      return messageError(context, "Please Enter Phone"); /// "Please Enter Phone",
      //return messageError(context, strings.get(135)); /// "Please Enter Email",
    if(_editControllerPhone.text.length!=10)
      return messageError(context, "Incorrect Phone"); /// "Incorrect Phone",

    // if (_editControllerPassword.text.isEmpty)
    //   return messageError(context, strings.get(136)); /// "Please Enter Password",

    var login = (String? code){
      setState(() {
        _editControllerCode.text=code!;
      });
      _mainModel.route("home");
    };

    var _goToCode = (){
      setState(() {
        otpsent=true;
      });
    };

    _waits(true);
    var ret = await _mainModel.userAccount.sendOTPCode(_editControllerPhone.text, context, login, _goToCode);
    _waits(false);
    if (ret != null)
      return messageError(context, ret);
    //_mainModel.route("home");
  }

  // _googleLogin() async {
  //   _waits(true);
  //   var ret = await _mainModel.googleLogin();
  //   _waits(false);
  //   if (ret != null)
  //     return messageError(context, ret);
  //   _mainModel.route("home");
  // }

  // _facebookLogin() async {
  //   _waits(true);
  //   var ret = await _mainModel.facebookLogin();
  //   _waits(false);
  //   if (ret != null)
  //     return messageError(context, ret);
  //   _mainModel.route("home");
  // }

//
  // Apple
  //
  // String _appleName = "";
  // AuthorizationCredentialAppleID? credential;
  //
  // _appleLogin() async {
  //   credential = await SignInWithApple.getAppleIDCredential(
  //     scopes: [
  //       AppleIDAuthorizationScopes.email,
  //       AppleIDAuthorizationScopes.fullName,
  //     ],
  //   );
  //   print(credential!.email);
  //   if (credential == null)
  //     return null;
  //   _waits(true);
  //   var ret = await _mainModel.appleLogin(credential);
  //   _waits(false);
  //   if (ret != null)
  //     return messageError(context, ret);
  //   _mainModel.route("home");
  // }
}


