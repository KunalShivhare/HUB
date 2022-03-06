import 'dart:io';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ondemandservice/ui/Subscription.dart';
import 'package:ondemandservice/model/blog.dart';
import 'package:ondemandservice/model/model.dart';
import 'package:ondemandservice/ui/login/phone.dart';
import 'package:ondemandservice/ui/documents.dart';
import 'package:ondemandservice/ui/provider.dart';
import 'package:ondemandservice/ui/login/register.dart';
import 'package:ondemandservice/ui/providersAll.dart';
import 'package:ondemandservice/ui/service.dart';
import 'package:ondemandservice/widgets/buttons/button2.dart';
import 'package:ondemandservice/widgets/dialogs/easyDialog2.dart';
import 'package:ondemandservice/widgets/loader/loader7.dart';
import 'package:provider/provider.dart';
import '../util.dart';
import 'account.dart';
import 'address/AddAddress.dart';
import 'address/addAddressMap.dart';
import 'address/AddressList.dart';
import 'address/mapDetails.dart';
import 'blog/blogAll.dart';
import 'blog/blogdetails.dart';
import 'booking/mapDetails.dart';
import 'bookings.dart';
import 'booking/booknow.dart';
import 'booking/booknow1.dart';
import 'booking/booknow2.dart';
import 'booking/booknow3.dart';
import 'category.dart';
import 'chat.dart';
import '../strings.dart';
import 'chat2.dart';
import 'dialogs/addAddress.dart';
import 'dialogs/filter.dart';
import 'favorite.dart';
import 'jobinfo.dart';
import 'lang.dart';
import 'login/forgot.dart';
import 'login/login.dart';
import 'login/otp.dart';
import 'theme.dart';
import 'package:ondemandservice/widgets/bottom/bottom13.dart';
import 'home.dart';
import 'notify.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  var windowWidth;
  var windowHeight;
  double windowSize = 0;
  String _dialogName = "";
  var _editControllerAddress = TextEditingController();
  var _editControllerName = TextEditingController();
  var _editControllerPhone = TextEditingController();
  late MainModel _mainModel;

  @override
  void initState() {
    _mainModel = Provider.of<MainModel>(context,listen:false);
    _init();
    checksignin();
    super.initState();
  }

  @override
  void dispose() {
    _mainModel.disposeChatNotify();
    _editControllerAddress.dispose();
    _editControllerName.dispose();
    _editControllerPhone.dispose();
    super.dispose();
  }

  _init() async {
    _waits(true);
    _mainModel.userAndNotifyListen(_redraw, context);
    var ret = await _mainModel.init2();
    _redraw();
    if (ret != null)
      messageError(context, ret);
    ret = await _mainModel.loadUsers();
    if (ret != null)
      return messageError(context, ret);
    _waits(false);
    ret = await loadBlog(true);
    if (ret != null)
      messageError(context, ret);
    _redraw();
  }

  Future<void> checksignin() async{
    print("checksign in");
    if(FirebaseAuth.instance.currentUser==null)
      _state='login';
    else if(FirebaseAuth.instance.currentUser!=null)
      _state='home';
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

  _openDialog(String val){
    _dialogName = val;
    _show = 1;
    _redraw();
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    windowSize = min(windowWidth, windowHeight);
    User? user = FirebaseAuth.instance.currentUser;
    _mainModel.setMainWindow(windowWidth, windowHeight, _redraw, _route, _openDialog);

    //print(_mainModel.newuser.toString()+" New User");

    if (user != null && _mainModel.newuser)
      _state = "register";

    if ( _state != "home" && _state != "otp" && _state != "phone" && _state != "register" && user == null && _state != "forgot"){
      _state = "login";
    }


    // ignore: unnecessary_statements
    context.watch<MainModel>().chatCount;

    var count = context.watch<MainModel>().numberOfUnreadMessages;
    if (_state == "notify" && count != 0)
      _mainModel.numberOfUnreadMessages = 0;
    _mainModel.currentPage = _state;

    _mainModel.drawState(_state);

    return WillPopScope(
      onWillPop: () async {
        if (_show != 0){
          _show = 0;
          _redraw();
          return false;
        }
        if ((_state == "home" && !_mainModel.searchActivate)
          || _state == "booking" || _state == "chat" || _state == "notify" || _state == "account"|| _state=="login"){
          _dialogName = "exit";
          _show = 1;
          _redraw();
          return false;
        }
        if (_state == "home" && _mainModel.searchActivate){
          _mainModel.searchActivate = false;
          _redraw();
          return false;
        }
        _mainModel.goBack();
        return false;
    },
    child: Scaffold(
        backgroundColor: (darkMode) ? blackColorTitleBkg : colorBackground,
        body: Directionality(
        textDirection: strings.direction,
        child: Stack(
          children: <Widget>[

            if (_state == "home")
              HomeScreen(openDialogFilter: (){
                setPriceRange(_mainModel);
                _dialogName = "filter";
                _show = 1;
                _redraw();
              },),
            if (_state == "booking")
              BookingScreen(),
            if (_state == "chat")
              ChatScreen(),
            if (_state == "notify")
              NotifyScreen(),
            if (_state == "account")
              AccountScreen(),

            Container(
              alignment: Alignment.bottomCenter,
              child: BottomBar13(colorBackground: (darkMode) ? Colors.black : Colors.white,
                  colorSelect: Colors.blue,
                  colorUnSelect: Colors.grey,
                  textStyle: theme.style10W600Grey,
                  textStyleSelect: theme.style12W600Blue,
                  radius: 10,
                  callback: (int y){
                    if (y == 0) _state = "home";
                    if (y == 1) _state = "booking";
                    if (y == 2) _state = "chat";
                    if (y == 3) _state = "notify";
                    if (y == 4) _state = "account";
                    _mainModel.callbackStackRemoveLast();
                    _redraw();
                  }, initialSelect: 0,
                  getItem: (){
                    if (_state == "home") return 0;
                    if (_state == "booking") return 1;
                    if (_state == "chat") return 2;
                    if (_state == "notify") return 3;
                    if (_state == "account") return 4;
                  },
                  text: [strings.get(6), // "Home",
                    strings.get(8), // "Booking",
                    strings.get(7), // "Chat",
                    strings.get(96), // "Notify",
                    strings.get(9), // "Account"
                  ],
                  getUnreadMessages: (int index){
                    if (index == 2)
                      return _mainModel.chatCount;
                    if (index == 3)
                      return _mainModel.numberOfUnreadMessages;
                    return 0;
                  },
                  icons: ["assets/ondemands/home.png",
                    "assets/ondemands/031-book.png",
                    "assets/ondemands/001-chat.png",
                    "assets/ondemands/notifyicon.png",
                    "assets/ondemands/008-user.png"]
              ),
            ),

            if (_state == "login")
              LoginScreen(),
            if (_state == "register")
              RegisterScreen(),
            if (_state == "service")
              ServicesScreen(),
            if (_state == "category")
              CategoryScreen(),
            if (_state == "favorite")
              FavoriteScreen(),
            if (_state == "phone")
              PhoneScreen(),
            if (_state == "otp")
              OTPScreen(),
            if (_state == "chat2")
              Chat2Screen(),
            if (_state == "language")
              LanguageScreen(openFromSplash: false),
            if (_state == "policy" || _state == "about" || _state == "terms")
              DocumentsScreen(source: _state),
            if (_state == "book")
              BookNowScreen(),
            if (_state == "book1")
              BookNowScreen1(),
            if (_state == "book2")
              BookNow2Screen(),
            if (_state == "book3")
              BookNow3Screen(),
            if (_state == "jobinfo")
              JobInfoScreen(),
            if (_state == "provider")
              ProvidersScreen(),
            if (_state == "blog_details")
              BlogDetailsScreen(),
            if (_state == "blog_all")
              BlogAllScreen(),
            if (_state == "address_list")
              AddressListScreen(),
            if (_state == "address_add")
              AddAddressScreen(),
            if (_state == "address_add_map")
              AddAddressMapScreen(),
            if (_state == "address_details")
              MapDetailsScreen(),
            if (_state == "booking_map_details")
              MapDetailsBookingScreen(),
            if (_state == "providers_all")
              ProvidersAllScreen(),
            if (_state == "forgot")
              ForgotScreen(),
            if(_state=="subscription")
              Subscription(),

            if (_wait)
              Center(child: Container(child: Loader7(color: mainColor,))),

            IEasyDialog2(setPosition: (double value){_show = value;}, getPosition: () {return _show;}, color: Colors.grey,
              getBody: _getDialogBody, backgroundColor: (darkMode) ? Colors.black : Colors.white,),

          ],
        ))

    ));
  }

  double _show = 0;
  late String _state="login";



  _route(String state){
    _state = state;

    if (_state.isEmpty)
      _state="home";

    _redraw();
  }

  Widget _getDialogBody(){
    if (_dialogName == "addAddress")
      return getBodyAddressDialog((){
        _show = 0;
        _redraw();
      }, _mainModel, _editControllerAddress, _editControllerName,
          _editControllerPhone, context);
    if (_dialogName == "filter")
      return getBodyFilterDialog(_redraw, (){_show = 0; _redraw();}, _mainModel);
    // exit
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(strings.get(178), /// Are you sure you want to exit?
            textAlign: TextAlign.center, style: theme.style14W800),
        SizedBox(height: 40,),
        Row(children: [
          Expanded(child: button2(strings.get(179), /// "No",
                (){
                _show = 0;
                _redraw();
              })),
          SizedBox(width: 10,),
          Expanded(child: button2(strings.get(180), /// "Exit",
                  (){
                    if (Platform.isAndroid) {
                      SystemNavigator.pop();
                    } else if (Platform.isIOS) {
                      exit(0);
                    }
              },))
        ],),
      ],
    );
  }
}


