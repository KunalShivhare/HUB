import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ondemandservice/model/service.dart';
import 'package:ondemandservice/ui/theme.dart';
import 'package:ondemandservice/util.dart';
import 'package:ondemandservice/widgets/appbars/appbar1.dart';
import 'package:ondemandservice/widgets/cards/card50.dart';
import 'package:ondemandservice/widgets/clippath/clippath23.dart';
import 'package:provider/provider.dart';

import '../strings.dart';
import '../model/localSettings.dart';
import '../model/model.dart';

class Subscription extends StatefulWidget {
  const Subscription({Key? key}) : super(key: key);

  @override
  _SubscriptionState createState() => _SubscriptionState();
}

class _SubscriptionState extends State<Subscription> {
  late MainModel _mainModel;
  var windowWidth;
  var windowHeight;
  double windowSize = 0;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _mainModel = Provider.of<MainModel>(context, listen: false);
    super.initState();
  }

  double _scroller = 20;

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    windowSize = min(windowWidth, windowHeight);
    // User? user = FirebaseAuth.instance.currentUser;
    return Scaffold(
        backgroundColor: (darkMode) ? blackColorTitleBkg : colorBackground,
        body: Directionality(
          textDirection: strings.direction,
          child: Stack(children: [
            NestedScrollView(
              controller: _scrollController,
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                      expandedHeight: windowHeight * 0.2,
                      automaticallyImplyLeading: false,
                      pinned: true,
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                      flexibleSpace: ClipPath(
                        clipper:
                            ClipPathClass23((_scroller < 5) ? 5 : _scroller),
                        child: Container(
                            color: (darkMode) ? Colors.black : Colors.white,
                            child: Stack(
                              children: [
                                FlexibleSpaceBar(
                                    collapseMode: CollapseMode.pin,
                                    //background: _title(),
                                    titlePadding: EdgeInsets.only(
                                        bottom: 10, left: 20, right: 20),
                                    title: _titleSmall())
                              ],
                            )),
                      ))
                ];
              },
              body: Container(
                width: windowWidth,
                height: windowHeight,
                child: Container(
                    width: windowWidth,
                    margin: EdgeInsets.only(left: 10, right: 10),
                    child: Stack(
                      children: [
                        InkWell(
                            //onTap:MaterialPageRoute(context,) ,
                            child:ListView(
                                    children: card(),
                                  )),
                      ],
                    )),
              ),
            ),
            appbar1(Colors.transparent,
                (darkMode) ? Colors.white : Colors.black, "", context, () {
              _mainModel.goBack();
            })
          ]),
        ));
    // body: Container(
    //   margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top+160, left: 0, right: 0),
    //   child:ListView(
    //   children: [
    //
    //
    //     ],),
    // ),
    //);
  }

  _titleSmall() {
    return Container(
        alignment: Alignment.bottomLeft,
        padding:
            EdgeInsets.only(bottom: _scroller, left: 20, right: 20, top: 25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Subscriptions",

              /// "Your Favorites",
              style: theme.style16W800,
            ),
            //SizedBox(height: 10,),
            // Text(strings.get(171), /// "View your favorite services",
            //   style: theme.style12W400,),
          ],
        ));
  }

  List<Widget> card() {
    List<Widget> ls = [];
    for (var item in _mainModel.service) {
      //print(getTextByLocale(item.name));
      var _tag = UniqueKey().toString();

      if(_mainModel.getSubtypevalue()=="Platinum")
        break;

      if(_mainModel.getSubtypevalue()=="Gold"){
        if(getTextByLocale(item.name).contains("Platinum")) {
          ls.add(InkWell(
              onTap: () {
                _openDetails(_tag, item);
              },
              child: Hero(
                  tag: _tag,
                  child: Container(
                      width: windowWidth,
                      height: windowHeight * 0.3,
                      margin: EdgeInsets.only(left: 10, right: 10),
                      child: Card50(item: item)))));
          ls.add(SizedBox(height: 20.0,));
          break;
        }

      }

      if(_mainModel.getSubtypevalue()=="Silver"){
        print("Silver");
        if(!getTextByLocale(item.name).contains("Silver Subscription") && getTextByLocale(item.name).contains("Subscription") ) {
          print("Silver miss");
          ls.add(InkWell(
              onTap: () {
                _openDetails(_tag, item);
              },
              child: Hero(
                  tag: _tag,
                  child: Container(
                      width: windowWidth,
                      height: windowHeight * 0.3,
                      margin: EdgeInsets.only(left: 10, right: 10),
                      child: Card50(item: item)))));
          ls.add(SizedBox(height: 20.0,));
        }
      }

      if(_mainModel.getSubtypevalue().isEmpty) {
        print("Empty Subscription");
        if (getTextByLocale(item.name).contains("Subscription")) {
          ls.add(InkWell(
              onTap: () {
                _openDetails(_tag, item);
              },
              child: Hero(
                  tag: _tag,
                  child: Container(
                      width: windowWidth,
                      height: windowHeight * 0.3,
                      margin: EdgeInsets.only(left: 10, right: 10),
                      child: Card50(item: item)))));
          ls.add(SizedBox(height: 20.0,));
        }
      }

      // if (getTextByLocale(item.name).contains('Subscription')) {
      //   ls.add(InkWell(
      //       onTap: () {
      //         _openDetails(_tag, item);
      //       },
      //       child: Hero(
      //           tag: _tag,
      //           child: Container(
      //               width: windowWidth,
      //               height: windowHeight * 0.3,
      //               margin: EdgeInsets.only(left: 10, right: 10),
      //               child: Card50(item: item)))));
      //   ls.add(SizedBox(height: 20.0,));
      //
      // }
    }
    print(ls.length);

    if(ls.isNotEmpty)
    return ls;


    if(ls.isEmpty)
    ls.add( Container(
      child: Center(child: Text("No Subscriptions Available")),
    ));
    return ls;
  }


  _openDetails(String _tag, ServiceData item) {
    // localSettings.callbackStack1 = "category";
    _mainModel.currentService = item;
    localSettings.serviceScreenTag = _tag;
    _mainModel.route("service");
  }
}
