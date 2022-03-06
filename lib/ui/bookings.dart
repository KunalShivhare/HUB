import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ondemandservice/model/localSettings.dart';
import 'package:ondemandservice/model/model.dart';
import 'package:ondemandservice/widgets/loader/loader7.dart';
import 'package:provider/provider.dart';
import '../util.dart';
import '../strings.dart';
import 'theme.dart';
import 'package:ondemandservice/widgets/cards/card43.dart';
import 'package:ondemandservice/widgets/clippath/clippath23.dart';

class BookingScreen extends StatefulWidget {
  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen>  with TickerProviderStateMixin{

  var windowWidth;
  var windowHeight;
  double windowSize = 0;
  late MainModel _mainModel;
  TabController? _tabController;

  @override
  void initState() {
    _mainModel = Provider.of<MainModel>(context,listen:false);
    _tabController = TabController(vsync: this, length: _mainModel.localAppSettings.statuses.length);
    _load();
    super.initState();
  }

  _load() async {
    _waits(true);


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

  @override
  void dispose() {
    _tabController!.dispose();
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
          children: <Widget>[

            Container(
              height: windowHeight,
              width: windowWidth,
              margin: EdgeInsets.only(top: 130),
              child: TabBarView(
                controller: _tabController,
                children: _tabBody()
              ),
            ),

            ClipPath(
                clipper: ClipPathClass23(20),
                child: Container(
              margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              width: windowWidth,
              color: (darkMode) ? Colors.black : Colors.white,
              padding: EdgeInsets.only(left: 20, right: 20, top: 30, bottom: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(strings.get(63), // "Booking",
                      style: theme.style20W800),
                  SizedBox(height: 20,),
                  TabBar(
                    labelColor: Colors.black,
                    indicatorWeight: 4,
                    isScrollable: true,
                    indicatorColor: mainColor,
                    tabs: _tabHeaders(),
                    controller: _tabController,
                  ),
                ],
              ),
            )),

            if (_wait)
              Center(child: Container(child: Loader7(color: mainColor,))),

          ],
        ))

    );
  }

  _tabHeaders(){
    List<Widget> list = [];
    for (var item in _mainModel.localAppSettings.statuses)
      list.add(Text(getTextByLocale(item.name),
          textAlign: TextAlign.center, style: theme.style12W800));
    return list;
  }

  _tabBody(){
    List<Widget> list = [];
    for (var item in _mainModel.localAppSettings.statuses)
        list.add(_tabChild(item.id, getTextByLocale(item.name)));
    return list;
  }

  _tabChild(String sort, String _text){
    List<Widget> list = [];
    bool _empty = true;
    for (var item in _mainModel.booking){
      if (item.status != sort)
        continue;
      var _date = strings.get(109); /// "Any Time",
      if (!item.anyTime)
        _date = _mainModel.localAppSettings.getDateTimeString(item.selectTime);
      list.add(InkWell(
          onTap: (){
            localSettings.jobInfo = item;
            _mainModel.route("jobinfo");
          },
          child: Container(
              margin: EdgeInsets.only(left: 10, right: 10),
              child: Card43(image: item.customerAvatar,
                text1: getTextByLocale(item.provider),
                text2: getTextByLocale(item.service),
                text3: _date,
                date: _text,
                dateCreating: _mainModel.localAppSettings.getDateTimeString(item.time),
                bookingId: item.id,
                icon: Icon(Icons.calendar_today_outlined, color: mainColor, size: 15,),
                bkgColor: (darkMode) ? Colors.black : Colors.white,
              ))
      ));
      list.add(SizedBox(height: 10,));
      _empty = false;
    }

    if (_empty) {
      list.add(Center(child:
      Container(
        width: windowWidth*0.7,
        height: windowWidth*0.7,
        child: theme.bookingNotFoundImageAsset ? Image.asset("assets/nofound.png", fit: BoxFit.contain) :
        CachedNetworkImage(
            imageUrl: theme.bookingNotFoundImage,
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
      //Image.asset("assets/nofound.png"))
      ));
      list.add(SizedBox(height: 10,));
      list.add(Center(child: Text(strings.get(150), style: theme.style18W800Grey,),)); /// "Not found ...",
    }

    list.add(SizedBox(height: 200,));
    return ListView(
      children: list,
    );
  }

}


