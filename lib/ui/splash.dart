import 'dart:async';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ondemandservice/model/localSettings.dart';
import 'package:provider/provider.dart';
import '../model/model.dart';
import '../util.dart';
import '../strings.dart';
import 'lang.dart';
import 'theme.dart';
import 'package:ondemandservice/widgets/loader/loader7.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  var windowWidth;
  var windowHeight;
  double windowSize = 0;
  late MainModel _mainModel;

  _startNextScreen(){
    if (_loaded) {
      if (!_startLoaded) {
        _startLoaded = true;
        Navigator.pop(context);
        if (localSettings.locale.isEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LanguageScreen(openFromSplash: true),
            ),
          );
        }else
          Navigator.pushNamed(context, "/ondemandservice_main");
      }
    }
  }

  @override
  void initState() {
    _mainModel = Provider.of<MainModel>(context,listen:false);
    super.initState();
    _load();
    startTime();
  }

  bool _loaded = false;
  bool _startLoaded = false;

  _load() async {
    await _mainModel.init(context);
    dprint("SplashScreen loaded languages");
    _loaded = true;
    _startNextScreen();
  }

  startTime() async {
    var duration = new Duration(seconds: 3);
    return Timer(duration, _startNextScreen);
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    windowSize = min(windowWidth, windowHeight);
    dprint("splash theme.logoAsset=${theme.logoAsset} theme.logo=${theme.logo}");
    return Scaffold(
        body: Stack(
          children: <Widget>[

          Container(color: (darkMode) ? Colors.black : colorBackground),

          Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: windowWidth*0.3,
                    height: windowWidth*0.3,
                    child: theme.logoAsset ? Image.asset("assets/ondemands/ondemand1.png", fit: BoxFit.contain) :
                    CachedNetworkImage(
                      imageUrl: theme.logo,
                      imageBuilder: (context, imageProvider) => Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.contain,
                            ),
                          ),
                        )
                    ),
                    // Image.network(
                    //     theme.logo,
                    //     fit: BoxFit.cover),
                  ),
                  SizedBox(height: 20,),
                  Text(strings.get(0), /// "HANDYMAN",
                      style: theme.style16W800),
                  SizedBox(height: 5,),
                  Text(strings.get(1), /// "SERVICE",
                      style: theme.style10W600Grey),
                  SizedBox(height: 20,),
                  Loader7(color: theme.splashColor)
                ],
              ),
            ),
            Container(
              alignment: Alignment.bottomCenter,
              child: UnconstrainedBox(
                  child: Container(
                      width: windowWidth,
                      height: windowWidth/2,
                      child: theme.splashImageAsset ?
                      Image.asset("assets/ondemands/ondemand2.png",
                          fit: BoxFit.cover
                      ) :
                      Image.network(
                          theme.splashImage,
                          fit: BoxFit.cover)
                  )
                  )
            )

          ],
        )

    );
  }

}


