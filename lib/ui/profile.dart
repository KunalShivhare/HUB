import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ondemandservice/model/model.dart';
import 'package:ondemandservice/util.dart';
import 'package:ondemandservice/widgets/loader/loader7.dart';
import 'package:provider/provider.dart';
import '../strings.dart';
import 'theme.dart';
import 'package:ondemandservice/widgets/appbars/appbar1.dart';
import 'package:ondemandservice/widgets/buttons/button2.dart';
import 'package:ondemandservice/widgets/cards/card42button.dart';
import 'package:ondemandservice/widgets/clippath/clippath23.dart';
import 'package:ondemandservice/widgets/edit/edit42.dart';
import 'package:ondemandservice/widgets/edit/edit43.dart';
import 'package:ondemandservice/widgets/image/image16.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>  with TickerProviderStateMixin{

  var windowWidth;
  var windowHeight;
  double windowSize = 0;
  var _editControllerName = TextEditingController();
  var _editControllerEmail = TextEditingController();
  var _editControllerPhone = TextEditingController();
  var _editControllerPassword1 = TextEditingController();
  var _editControllerPassword2 = TextEditingController();
  late MainModel _mainModel;

  @override
  void initState() {
    _mainModel = Provider.of<MainModel>(context,listen:false);
    _editControllerEmail.text = _mainModel.userEmail;
    _editControllerName.text = _mainModel.userName;
    _editControllerPhone.text = _mainModel.userPhone;
    super.initState();
  }

  @override
  void dispose() {
    _editControllerName.dispose();
    _editControllerEmail.dispose();
    _editControllerPhone.dispose();
    _editControllerPassword1.dispose();
    _editControllerPassword2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    windowSize = min(windowWidth, windowHeight);

    var _enablePhoneEdit = true;
    if (_mainModel.localAppSettings.isOtpEnable())
      _enablePhoneEdit = false;
    if (_mainModel.userSocialLogin.isNotEmpty)
      _enablePhoneEdit = true;

    return Scaffold(
        backgroundColor: (darkMode) ? blackColorTitleBkg : colorBackground,
        body: Directionality(
        textDirection: strings.direction,
        child: Stack(
          children: <Widget>[

            Container(
              margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top+130, left: 20, right: 20),
              child: ListView(
                children: [

                  Container(
                    padding: EdgeInsets.only(left: 20, right: 20, top: 20),
                    decoration: BoxDecoration(
                      color: (darkMode) ? Colors.black : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        edit42(strings.get(21), // "Name",
                            _editControllerName,
                            strings.get(22), // "Enter your name",
                            ),

                        SizedBox(height: 20,),

                        if (_mainModel.userSocialLogin.isEmpty)
                          edit42(strings.get(23), // "Email",
                              _editControllerEmail,
                              strings.get(24), // "Enter your Email",
                              ),

                        SizedBox(height: 20,),

                        edit42Phone(strings.get(25), // "Phone number",
                            theme.style14W600Grey, _editControllerPhone,
                            strings.get(26), // "Enter your Phone number",
                            _enablePhoneEdit ? theme.style15W400 : theme.style14W600Grey,
                            Colors.grey, _enablePhoneEdit
                        ),
                        if (!_enablePhoneEdit)
                          SizedBox(height: 5,),
                        if (!_enablePhoneEdit)
                          Text(strings.get(226), style: theme.style12W600Orange,), /// Your phone number verified. You can't edit phone number

                        SizedBox(height: 20,),

                        Container(
                          margin: EdgeInsets.all(20),
                          child: button2s(strings.get(31), // "SAVE",
                              theme.style16W800White, mainColor, 50, _changeInfo, true),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20,),

                  // if (_mainModel.userSocialLogin.isEmpty)
                  //   Column(
                  //     children: [
                  //       Text(strings.get(32), // "Change password",
                  //         style: theme.style16W800,),
                  //
                  //       SizedBox(height: 20,),
                  //
                  //       Container(
                  //         padding: EdgeInsets.only(left: 20, right: 20, top: 20),
                  //         decoration: BoxDecoration(
                  //           color: (darkMode) ? Colors.black : Colors.white,
                  //           borderRadius: BorderRadius.circular(10),
                  //         ),
                  //         child: Column(
                  //             children: [
                  //               Edit43(
                  //                   text: strings.get(33), // "New password",
                  //                   textStyle: theme.style14W600Grey,
                  //                   controller: _editControllerPassword1,
                  //                   hint: strings.get(34), // "Enter Password",
                  //                   color: (darkMode) ? Colors.white : Colors.black),
                  //
                  //               SizedBox(height: 20,),
                  //
                  //               Edit43(
                  //                   text: strings.get(35), // "Confirm New password",
                  //                   textStyle: theme.style14W600Grey,
                  //                   controller: _editControllerPassword2,
                  //                   hint: strings.get(36), // "Enter Password",
                  //                   color: (darkMode) ? Colors.white : Colors.black),
                  //
                  //               SizedBox(height: 20,),
                  //
                  //               Container(
                  //                 margin: EdgeInsets.all(20),
                  //                 child: button2s(strings.get(37), // "CHANGE PASSWORD",
                  //                     theme.style16W800White, mainColor, 50, _changePassword, true),
                  //               ),
                  //             ]),
                  //   ),
                  // ]),

                  SizedBox(height: 120,),
                ],
              ),
            ),

            InkWell(
              onTap: _photo,
                child: ClipPath(
                clipper: ClipPathClass23(20),
                child: Container(
                    margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                    width: windowWidth,
                    child: card42button(
                        strings.get(38), /// "My Profile",
                        theme.style20W800,
                        strings.get(39), /// "Everything about you",
                        theme.style14W600Grey,
                        Opacity(opacity: 0.5,
                        child:
                        theme.profileLogoAsset ? Image.asset("assets/ondemands/ondemand12.png", fit: BoxFit.cover) :
                        CachedNetworkImage(
                            imageUrl: theme.profileLogo,
                            imageBuilder: (context, imageProvider) => Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                        ),
                        //Image.asset("assets/ondemands/ondemand12.png", fit: BoxFit.cover)
                        ),
                        image16(_mainModel.userAvatar.isNotEmpty ?
                        CachedNetworkImage(
                            imageUrl: _mainModel.userAvatar,
                            imageBuilder: (context, imageProvider) => Container(
                              child: Container(
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.cover,
                                    )),
                              ),
                            )
                        ) : Image.asset("assets/user5.png", fit: BoxFit.cover), 80, Colors.white),
                        windowWidth, (darkMode) ? Colors.black : Colors.white, _photo
                    )
                ))),

            appbar1(Colors.transparent, (darkMode) ? Colors.white : Colors.black, "", context, () {
              Navigator.pop(context);
            }),

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

  _photo() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final pickedFile = await ImagePicker().getImage(
          maxWidth: 400,
          maxHeight: 400,
          source: ImageSource.camera);
      if (pickedFile != null) {
        dprint("Photo file: ${pickedFile.path}");
        _waits(true);
        var ret = await _mainModel.userAccount.uploadAvatar(pickedFile.path);
        _waits(false);
        if (ret != null)
          messageError(context, ret);
      }
    }
  }

  _changePassword() async {
    if (_editControllerPassword1.text.isEmpty)
      return messageError(context, strings.get(34)); /// "Enter Password"
    if (_editControllerPassword2.text.isEmpty)
      return messageError(context, strings.get(151)); /// "Enter Confirm Password"
    if (_editControllerPassword1.text != _editControllerPassword2.text)
      return messageError(context, strings.get(140)); /// "Passwords are not equal",

    _waits(true);
    var ret = await _mainModel.changePassword(_editControllerPassword1.text);
    _waits(false);
    if (ret != null)
      messageError(context, ret);
    else
      messageOk(context, strings.get(152)); /// "Password changed",
  }

  _changeInfo() async {
    if (_editControllerName.text.isEmpty)
      return messageError(context, strings.get(153)); /// "Please Enter name"

    _waits(true);
    var ret = await _mainModel.changeInfo(_editControllerName.text,
        _editControllerEmail.text, _editControllerPhone.text);
    _waits(false);
    if (ret != null)
      messageError(context, ret);
    else
      messageOk(context, strings.get(154)); /// "Data saved",
  }

}


