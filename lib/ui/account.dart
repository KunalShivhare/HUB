import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ondemandservice/model/localSettings.dart';
import 'package:ondemandservice/model/model.dart';
import 'package:provider/provider.dart';
import 'profile.dart';
import '../strings.dart';
import 'theme.dart';
import 'package:ondemandservice/widgets/buttons/button197.dart';
import 'package:ondemandservice/widgets/buttons/button198.dart';
import 'package:ondemandservice/widgets/cards/card42button.dart';
import 'package:ondemandservice/widgets/clippath/clippath23.dart';
import 'package:ondemandservice/widgets/image/image16.dart';

class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen>  with TickerProviderStateMixin{

  var windowWidth;
  var windowHeight;
  double windowSize = 0;
  late MainModel _mainModel;

  @override
  void initState() {
    _mainModel = Provider.of<MainModel>(context,listen:false);
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
          children: <Widget>[

            Container(
                margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top+160, left: 0, right: 0),
                child: ListView(
                    children: [
                      SizedBox(height: 10,),

                      Button197(color: (darkMode) ? Colors.black : Colors.white,
                          text: 'Subscription', /// "Subscription",
                          textStyle: theme.style16W800,
                          text2: 'Subscription', /// "View your favorite services",
                          textStyle2: theme.style12W600Grey,
                          pressButton: (){
                            _mainModel.route("subscription");
                          },
                          icon: Icon(Icons.bookmark, color: Colors.blue,)
                      ),



                      SizedBox(height: 10,),

                      Button197(color: (darkMode) ? Colors.black : Colors.white,
                          text: strings.get(170), /// "Your Favorites",
                          textStyle: theme.style16W800,
                          text2: strings.get(171), /// "View your favorite services",
                          textStyle2: theme.style12W600Grey,
                          pressButton: (){
                            _mainModel.route("favorite");
                          },
                          icon: Icon(Icons.favorite, color: Colors.blue,)
                      ),

                      SizedBox(height: 10,),

                      Button197(color: (darkMode) ? Colors.black : Colors.white,
                          text: strings.get(10), // "Change Language",
                          textStyle: theme.style16W800,
                          text2: strings.get(11), // "Set your Preferred language",
                          textStyle2: theme.style12W600Grey,
                          pressButton: (){
                            _mainModel.route("language");
                          },
                          icon: Icon(Icons.padding, color: Colors.blue,)
                      ),

                      SizedBox(height: 10,),

                      Button198(color: (darkMode) ? Colors.black : Colors.white,
                          text: strings.get(12), // "Enable Dark Mode",
                          textStyle: theme.style16W800,
                          text2: strings.get(13), // "Set you favorite mode",
                          textStyle2: theme.style12W600Grey,
                          icon: Icon(Icons.dark_mode, color: (darkMode) ? Colors.white : Colors.black,),
                          checkValue: darkMode,
                          rColor: Colors.grey,
                          callback: (bool val){
                            localSettings.setDarkMode(val);
                            darkMode = val;
                            theme = OnDemandServiceTheme();
                            _mainModel.redraw();
                          }
                      ),

                      SizedBox(height: 10,),

                      Button197(color: (darkMode) ? Colors.black : Colors.white,
                          text: strings.get(14), /// "Privacy Policy",
                          textStyle: theme.style16W800,
                          text2: strings.get(15), /// "Known our Privacy Policy",
                          textStyle2: theme.style12W600Grey,
                          pressButton: (){
                            _mainModel.route("policy");
                            //widget.callback("policy", "account");
                          },
                          icon: Icon(Icons.privacy_tip_outlined, color: Colors.blue,)
                      ),

                      SizedBox(height: 10,),

                      Button197(color: (darkMode) ? Colors.black : Colors.white,
                          text: strings.get(146), /// "About Us",
                          textStyle: theme.style16W800,
                          text2: strings.get(147), /// "Known About Us",
                          textStyle2: theme.style12W600Grey,
                          pressButton: (){
                            _mainModel.route("about");
                            //widget.callback("about", "account");
                          },
                          icon: Icon(Icons.settings_applications, color: Colors.blue,)
                      ),

                      SizedBox(height: 10,),

                      Button197(color: (darkMode) ? Colors.black : Colors.white,
                          text: strings.get(148), /// "Terms & Conditions",
                          textStyle: theme.style16W800,
                          text2: strings.get(149), /// "Known Terms & Conditions",
                          textStyle2: theme.style12W600Grey,
                          pressButton: (){
                            _mainModel.route("terms");
                          },
                          icon: Icon(Icons.copy, color: Colors.blue,)
                      ),

                      SizedBox(height: 10,),

                      Button197(color: (darkMode) ? Colors.black : Colors.white,
                          text: strings.get(19), /// "Notifications",
                          textStyle: theme.style16W800,
                          text2: strings.get(20), // "Lots of important information",
                          textStyle2: theme.style12W600Grey,
                          pressButton: (){
                            _mainModel.route("notify");
                          },
                          icon: Icon(Icons.notifications, color: Colors.blue,)
                      ),

                      SizedBox(height: 10,),

                      Button197(color: (darkMode) ? Colors.black : Colors.white,
                          text: strings.get(17), /// "Log Out",
                          textStyle: theme.style16W800,
                          text2: strings.get(18), // "End the session",
                          textStyle2: theme.style12W600Grey,
                          pressButton: _logout,
                          icon: Icon(Icons.logout, color: Colors.blue,)
                      ),

                      SizedBox(height: 120,),

                    ])
            ),


            ClipPath(
                clipper: ClipPathClass23(20),
                child: Container(
                    margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                    width: windowWidth,
                    color: (darkMode) ? Colors.black : Colors.white,
                    padding: EdgeInsets.only(top: 20, bottom: 20),
                    child: card42button(
                        _mainModel.userName,
                        theme.style20W800,
                        strings.get(16), /// "Press for view profile",
                        theme.style14W600Grey,
                        Opacity(opacity: 0.5,
                        child:
                        theme.accountLogoAsset ? Image.asset("assets/ondemands/ondemand12.png", fit: BoxFit.cover) :
                        CachedNetworkImage(
                            imageUrl: theme.accountLogo,
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
                        windowWidth, (darkMode) ? Colors.black : Colors.white, _openProfile
                    )
                ))

          ],
        )

    ));
  }

  _openProfile(){
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(),
      ),
    );
  }

  _logout() async {
    await _mainModel.logout();
    _mainModel.redraw();
  }

  // _openAllreviews(){
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => ReviewsScreen(),
  //     ),
  //   );
  // }


}


