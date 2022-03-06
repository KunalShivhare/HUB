import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ondemandservice/model/localSettings.dart';
import 'package:ondemandservice/model/model.dart';
import 'package:ondemandservice/model/payments/FlutterwavePayment.dart';
import 'package:ondemandservice/model/payments/paypal/PaypalPayment.dart';
import 'package:ondemandservice/model/payments/paystack.dart';
import 'package:ondemandservice/model/payments/razorpay.dart';
import 'package:ondemandservice/model/payments/stripe.dart';
import 'package:ondemandservice/widgets/checkbox/checkbox43.dart';
import 'package:ondemandservice/widgets/loader/loader7.dart';
import '../../strings.dart';
import '../../util.dart';
import '../theme.dart';
import 'package:ondemandservice/widgets/appbars/appbar1.dart';
import 'package:ondemandservice/widgets/buttons/button1.dart';
import 'package:ondemandservice/widgets/buttons/button2.dart';
import 'package:ondemandservice/widgets/clippath/clippath23.dart';
import 'package:ondemandservice/widgets/dialogs/easyDialog2.dart';
import 'package:ondemandservice/widgets/image/image11.dart';
import 'package:provider/provider.dart';

class BookNow3Screen extends StatefulWidget {
  @override
  _BookNow3ScreenState createState() => _BookNow3ScreenState();
}

class _BookNow3ScreenState extends State<BookNow3Screen> {

  var windowWidth;
  var windowHeight;
  double windowSize = 0;
  ScrollController _scrollController = ScrollController();
  var _controllerSearch = TextEditingController();
  var _editControllerHint = TextEditingController();
  late MainModel _mainModel;

  @override
  void initState() {
    _mainModel = Provider.of<MainModel>(context,listen:false);
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  double _scroller = 20;
  _scrollListener() {
    var _scrollPosition = _scrollController.position.pixels;
    _scroller = 20-(_scrollPosition/(windowHeight*0.1/20));
    if (_scroller < 0)
      _scroller = 0;
    setState(() {
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controllerSearch.dispose();
    _editControllerHint.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(localSettings.getTotal(_mainModel) * 100==0)
      localSettings.paymentMethod=1;
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    windowSize = min(windowWidth, windowHeight);
    return Scaffold(
      backgroundColor: (darkMode) ? blackColorTitleBkg : colorBackground,
      body: Directionality(
      textDirection: strings.direction,
      child: Stack(
          children: [
            NestedScrollView(
              controller: _scrollController,
              headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                      expandedHeight: windowHeight*0.2,
                      automaticallyImplyLeading: false,
                      pinned: true,
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                      flexibleSpace: ClipPath(
                        clipper: ClipPathClass23((_scroller < 5) ? 5 : _scroller),
                        child: Container(
                            child: Stack(
                              children: [
                                FlexibleSpaceBar(
                                    collapseMode: CollapseMode.pin,
                                    background: _title(),
                                    titlePadding: EdgeInsets.only(bottom: 10, left: 20, right: 20),
                                )
                              ],
                            )),
                      ))
                ];
              },
              body: Container(
                width: windowWidth,
                height: windowHeight,
                child: _body(),
              ),
            ),

            appbar1((_scroller > 1) ? Colors.transparent :
                  (darkMode) ? Colors.black : Colors.white,
                (darkMode) ? Colors.white : Colors.black,
                (_scroller > 5) ? "" : getTextByLocale(_mainModel.currentService.name),
                context, () {_mainModel.goBack();}),

            if (!_booking)
            Container(
              alignment: Alignment.bottomCenter,
              child: button1a(strings.get(113), /// "CONFIRM & BOOKING NOW"
                  theme.style16W800White,
                  mainColor, _book, localSettings.getTotal(_mainModel) * 100==0?true:localSettings.paymentMethod>1?true:false),
            ),

            IEasyDialog2(setPosition: (double value){_show = value;}, getPosition: () {return _show;}, color: Colors.grey,
              getBody: _getDialogBody, backgroundColor: (darkMode) ? Colors.black : Colors.white,),

            if (_wait)
              Center(child: Container(child: Loader7(color: mainColor,))),

          ]),
    ));
  }

  bool _booking = false;
  double _show = 0;

  _book() async {
    double _total = localSettings.getTotal(_mainModel) * 100;
    print("Service Final Price: "+_total.toString());
    if (localSettings.paymentMethod == 1)
      _appointment(strings.get(81)); /// "Cash payment",
    if (localSettings.paymentMethod == 2){
      StripeModel _stripe = StripeModel();
      _waits(true);
      try {
        _stripe.init(_mainModel.localAppSettings.stripeKey);
        var t = _total.toInt();
        _stripe.openCheckoutCard(t, "", "",
            _mainModel.localAppSettings.razorpayName,
            _mainModel.localAppSettings.code,
            _mainModel.localAppSettings.stripeSecretKey, _appointment);
      }catch(ex){
        _waits(false);
        print(ex.toString());
        messageError(context, ex.toString());
      }
    }
    if (localSettings.paymentMethod == 3){
      _waits(true);
      RazorpayModel _razorpayModel = RazorpayModel();
      _razorpayModel.init();

      var t = _total.toInt();
      _razorpayModel.openCheckout(t.toString(), "", "",
          _mainModel.localAppSettings.razorpayName,
          _mainModel.localAppSettings.code,
          _mainModel.localAppSettings.razorpayKey,
          _appointment, (String err){messageError(context, err);}
      );
    }
    if (localSettings.paymentMethod == 4){
      String _total = localSettings.getTotalString(_mainModel);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaypalPayment(
              currency: _mainModel.localAppSettings.code,
              userFirstName: "",
              userLastName: "",
              userEmail: "",
              payAmount: _total,
              secret: _mainModel.localAppSettings.paypalSecretKey,
              clientId: _mainModel.localAppSettings.paypalClientId,
              sandBoxMode: _mainModel.localAppSettings.paypalSandBox.toString(),
              onFinish: (w){
                _appointment("PayPal: $w");
              }
          ),
        ),
      );
    }
    //
    // Flutterwave
    //
    if (localSettings.paymentMethod == 5){
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FlutterwavePayment(
              onFinish: (String w){
                _appointment("Flutterwave: $w");
                _waits(false);
              }
          ),
        ),
      );
      // _onerror(String ret){
      //   messageError(context, ret);
      // }
      // var _total = localSettings.getTotal(_mainModel);
      // var ret = await FlutterWaveModel().handleCheckout(_total,
      //     _mainModel.userEmail, _mainModel.localAppSettings.code,
      //     _mainModel.localAppSettings.flutterWaveEncryptionKey, _mainModel.localAppSettings.flutterWavePublicKey,
      //     context, _mainModel.userPhone, _mainModel.userName, "1", _onerror);
      // if (ret != null)
      //   _appointment("FW: $ret");
    }
    //
    // Paystack
    //
    if (localSettings.paymentMethod == 6){
      var _total = localSettings.getTotal(_mainModel);
      var paystack = PayStackModel();
      var ret = await paystack.handleCheckout(_total, _mainModel.userEmail, context, _mainModel.localAppSettings.payStackKey);
      if (ret != null)
        _appointment(ret);
    }
    _waits(false);
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

  Widget _getDialogBody(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        UnconstrainedBox(
            child: Container(
              height: windowWidth/3,
              width: windowWidth/3,
              child: image11(
                  theme.booking5LogoAsset ? Image.asset("assets/ondemands/ondemand33.png", fit: BoxFit.contain) :
                  CachedNetworkImage(
                      imageUrl: theme.booking5Logo,
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.contain,
                          ),
                        ),
                      )
                  ),
                  //Image.asset("assets/ondemands/ondemand33.png", fit: BoxFit.contain)
                20),
            )),
        SizedBox(height: 20,),
        Text(strings.get(116), // "Thank you!",
            textAlign: TextAlign.center, style: theme.style20W800),
        SizedBox(height: 20,),
        Text(strings.get(115), // "Your booking has been successfully submitted, you will receive a confirmation soon."
            textAlign: TextAlign.center, style: theme.style14W400),
        SizedBox(height: 40,),
        Container(
            alignment: Alignment.center,
            child: Container(
                width: windowWidth/2,
                child: button2(strings.get(114), // "Ok",
                        (){
                      print("button pressed");
                      setState(() {
                        _show = 0;
                      });
                      _mainModel.route("home");
                    }))),
        SizedBox(height: 20,),
      ],
    );
  }

  _book2(){
    _booking = true;
    setState(() {
      _show = 1;
    });
  }

  _title() {
    var _data = _mainModel.getTitleImage();
    if (_data.serverPath.isEmpty)
      return Container();
    return Container(
      color: (darkMode) ? blackColorTitleBkg : colorBackground,
      height: windowHeight * 0.3,
      width: windowWidth,
      child: Stack(
        children: [
          Container(
              alignment: Alignment.bottomRight,
              child: Container(
                width: windowWidth,
                margin: EdgeInsets.only(bottom: 10),
                child: CachedNetworkImage(
                    imageUrl: _data.serverPath,
                    imageBuilder: (context, imageProvider) => Container(
                      width: double.maxFinite,
                      alignment: Alignment.bottomRight,
                      child: Container(
                        //width: height,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            )),
                      ),
                    )
                ),
              )),
        ],
      ),
    );
  }

  _body(){
    List<Widget> list = [];

    list.add(SizedBox(height: 10,));

    list.add(Container(
        padding: EdgeInsets.all(20),
        color: (darkMode) ? Colors.black : Colors.white,
        child: Row(
          children: [
            Expanded(child: Text(strings.get(77), // "Total",
                style: theme.style14W400)),
            Text(localSettings.getTotalString(_mainModel), style: theme.style16W800Orange,)
          ],
        ),
    ));

    // if(!getTextByLocale(_mainModel.currentService.name).contains('Subscription'))
    //   if(_mainModel.getSubvalue()!=true)
    // list.add(Container(
    //   margin: EdgeInsets.only(left: 10, right: 10, top: 30, bottom: 10),
    //   padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
    //   decoration: BoxDecoration(
    //     color: (darkMode) ? Colors.black : Colors.white,
    //     borderRadius: BorderRadius.circular(10),
    //   ),
    //   child: checkBox43(strings.get(81), // "Cash payment",
    //       theme.booking4CheckBoxColor, "assets/cache.png",
    //       theme.style14W800,
    //       localSettings.paymentMethod == 1, (val) {
    //         if (val) {
    //           localSettings.paymentMethod = 1;
    //           setState(() {});
    //         }
    //       }),
    // ));

    //
    // Stripe
    //
    if (_mainModel.localAppSettings.stripeEnable)
      list.add(Container(
        margin: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
        padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
        decoration: BoxDecoration(
          color: (darkMode) ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: checkBox43("Stripe",
            theme.booking4CheckBoxColor, "assets/stripe.png",
            theme.style14W800,
            localSettings.paymentMethod == 2, (val) {
              if (val) {
                localSettings.paymentMethod = 2;
                setState(() {});
              }
            }),
      ));

    //
    // Razorpay
    //
    if(!(localSettings.getTotalString(_mainModel)=="0"))
    if (_mainModel.localAppSettings.razorpayEnable)
      list.add(Container(
          margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
          padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
          decoration: BoxDecoration(
            color: (darkMode) ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: checkBox43("Razorpay",
              theme.booking4CheckBoxColor, "assets/razorpay.png",
              theme.style14W800,
              localSettings.paymentMethod == 3, (val) {
                if (val) {
                  localSettings.paymentMethod = 3;
                  setState(() {});
                }
              })));

    //
    // Paypal
    //
    if (_mainModel.localAppSettings.paypalEnable)
      list.add(Container(
          margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
          padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
          decoration: BoxDecoration(
            color: (darkMode) ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: checkBox43("Pay Pal",
              theme.booking4CheckBoxColor, "assets/paypal.png",
              theme.style14W800,
                localSettings.paymentMethod == 4, (val) {
                if (val) {
                  localSettings.paymentMethod = 4;
                  setState(() {});
                }
              })));

    //
    // Flutterwave
    //
    if (_mainModel.localAppSettings.flutterWaveEnable)
      list.add(Container(
          margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
          padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
          decoration: BoxDecoration(
            color: (darkMode) ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: checkBox43("Flutterwave",
              theme.booking4CheckBoxColor, "assets/flutterwave.png",
              theme.style14W800,
              localSettings.paymentMethod == 5, (val) {
                if (val) {
                  localSettings.paymentMethod = 5;
                  setState(() {});
                }
              })));

    //
    // Paystack
    //
    if (_mainModel.localAppSettings.payStackEnable)
      list.add(Container(
          margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
          padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
          decoration: BoxDecoration(
            color: (darkMode) ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: checkBox43("Paystack",
              theme.booking4CheckBoxColor, "assets/paystack.png",
              theme.style14W800,
              localSettings.paymentMethod == 6, (val) {
                if (val) {
                  localSettings.paymentMethod = 6;
                  setState(() {});
                }
              })));

    list.add(SizedBox(height: 150,));
    return Container(
        child: ListView(
          padding: EdgeInsets.only(top: 0),
          children: list,
        )
    );
  }

  _appointment(String paymentMethod) async {
    dprint("_appointment $paymentMethod");
    var ret = await _mainModel.finish(paymentMethod, _mainModel);
    if (ret != null)
      return messageError(context, ret);
    _book2();
    localSettings.clearBookData();
  }
}
