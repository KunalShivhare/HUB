import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ondemandservice/model/localSettings.dart';
import 'package:ondemandservice/model/model.dart';
import 'package:ondemandservice/ui/booking/pricingTable.dart';
import 'package:ondemandservice/ui/elements/widgets.dart';
import 'package:ondemandservice/util.dart';
import 'package:provider/provider.dart';
import '../../strings.dart';
import '../addons.dart';
import '../theme.dart';
import 'package:ondemandservice/widgets/appbars/appbar1.dart';
import 'package:ondemandservice/widgets/buttons/button1.dart';
import 'package:ondemandservice/widgets/buttons/button206.dart';
import 'package:ondemandservice/widgets/clippath/clippath23.dart';
import 'package:ondemandservice/widgets/edit/edit42.dart';

class BookNowScreen1 extends StatefulWidget {
  @override
  _BookNowScreen1State createState() => _BookNowScreen1State();
}

class _BookNowScreen1State extends State<BookNowScreen1> {

  var windowWidth;
  var windowHeight;
  double windowSize = 0;
  ScrollController _scrollController = ScrollController();
  var _controllerSearch = TextEditingController();
  var _editControllerCoupon = TextEditingController();
  ScrollController _scrollController2 = ScrollController();

  late MainModel _mainModel;

  @override
  void initState() {
    _mainModel = Provider.of<MainModel>(context,listen:false);
    _scrollController.addListener(_scrollListener);
    _editControllerCoupon.text = localSettings.couponCode;
    print(getTextByLocale(_mainModel.currentService.name));
    print(_mainModel.currentService.price.first.discPrice.toString());
    print(localSettings.price.discPrice);
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
    _scrollController2.dispose();
    _controllerSearch.dispose();
    _editControllerCoupon.dispose();
    super.dispose();
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

            Container(
              alignment: Alignment.bottomCenter,
              child: button1a(strings.get(46), /// "CONTINUE"
                  theme.style16W800White,
                  mainColor, (){
                    _mainModel.route("book2");
                  }, true),
            ),

          ])),
    );
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

    list.add(SizedBox(height: 20,));

    for (var item in _mainModel.currentService.price){
      List<Widget> list2 = [];
      list2.add((item.image.serverPath.isNotEmpty) ?
      Container(
          width: 30,
          height: 30,
          child: Image.network(item.image.serverPath, fit: BoxFit.contain))
          : Container(
          width: 30,
          height: 30));
      list2.add(SizedBox(width: 10,));
      list2.add(Expanded(child: Text(getTextByLocale(item.name), style: theme.style14W400)));
      list2.add(SizedBox(width: 5,));
      getPriceText(item, list2, _mainModel);
      list.add(InkWell(
          onTap: (){
            for (var item in _mainModel.currentService.price)
              item.selected = false;
            item.selected = true;
            localSettings.price = item;
            _redraw();
          },
          child: Container(
              color: (item.selected) ? Colors.grey.withAlpha(60) : Colors.transparent,
              margin: EdgeInsets.only(bottom: 8),
              padding: EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 10),
              child: Row(children: list2))
      ));
    }

    list.add(SizedBox(height: 10,));

    list.add(Container(
      color: (darkMode) ? Colors.black : Colors.white,
      padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
      child: Column(
        children: [
          edit42Listener(strings.get(107), /// "Coupon Code",
            _editControllerCoupon,
            "COUPON1",
            (String val){
                localSettings.couponCode = val;
                setState(() {
                });
              }
          ),
        if (localSettings.couponCode.isNotEmpty)
          SizedBox(height: 10,),
        if (localSettings.couponCode.isNotEmpty)
          Center(child: Text(_mainModel.couponInfo(),
            style: theme.style16W800, textAlign: TextAlign.center,))
        ],
      )));

    list.add(SizedBox(height: 20,));


    if(!_mainModel.currentService.name.first.text.contains("Subscription"))
    list.add(Container(
        color: (darkMode) ? Colors.black : Colors.white,
        padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
        child: Row(
          children: [
            Expanded(child: Text(strings.get(75), /// "Quantity",
                style: theme.style12W600Grey,)),
            button206(localSettings.count, TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.red),
                Colors.transparent, (darkMode) ? Colors.white : Colors.black, Colors.blue.withAlpha(50),
                    (int value){localSettings.count = value; setState(() {});})
          ],
        )));

    list.add(SizedBox(height: 20,));

    listAddons(list, windowWidth, _redraw, _mainModel);

    list.add(pricingTable(context, _mainModel));

    list.add(SizedBox(height: 150,));
    return Container(
        child: ListView(
          padding: EdgeInsets.only(top: 0),
          children: list,
        )
    );
  }

  _redraw(){
    if (mounted)
      setState(() {
      });
  }
}
