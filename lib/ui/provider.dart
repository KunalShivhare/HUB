import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ondemandservice/model/model.dart';
import 'package:ondemandservice/ui/theme.dart';
import 'package:ondemandservice/util.dart';
import 'package:ondemandservice/widgets/appbars/appbar1.dart';
import 'package:ondemandservice/widgets/cards/card50a.dart';
import 'package:ondemandservice/widgets/clippath/clippath23.dart';
import 'package:provider/provider.dart';

import '../strings.dart';
import 'gallery.dart';

class ProvidersScreen extends StatefulWidget {
  @override
  _ProvidersScreenState createState() => _ProvidersScreenState();
}

class _ProvidersScreenState extends State<ProvidersScreen> {
  var windowWidth;
  var windowHeight;
  double windowSize = 0;
  ScrollController _scrollController = ScrollController();
  var _controllerSearch = TextEditingController();
  late MainModel _mainModel;

  @override
  void dispose() {
    _controllerSearch.dispose();
    _scrollController.dispose();
    super.dispose();
  }

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
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    windowSize = min(windowWidth, windowHeight);
    return Container(
      color: (darkMode) ? Colors.black : Colors.white,
      width: windowWidth,
      height: windowHeight,
      child: _body2(),
    );
  }

  _body2(){
    return Stack(
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
              (_scroller > 5) ? "" : getTextByLocale(_mainModel.currentProvider.name), context,
              () {
                _mainModel.goBack();
                  // if (_mainModel.returnFromProvider == "home") {
                  //   _mainModel.returnFromProvider = "";
                  //   _mainModel.goBack();
                  // }else
                  //   widget.callback("service");
          }),

          // Container(
          //   alignment: Alignment.bottomCenter,
          //   child: button1a(strings.get(102), // "Book This Service"
          //       theme.style16W800White,
          //       mainColor, (){}, true),
          // ),

        ]);
  }

  _title() {
    var imageUpperServerPath = _mainModel.currentProvider.imageUpperServerPath;
    return Container(
      color: (darkMode) ? blackColorTitleBkg : colorBackground,
      height: windowHeight * 0.3,
      width: windowWidth,
      child: Container(
          width: windowWidth,
          margin: EdgeInsets.only(bottom: 10),
          child: imageUpperServerPath.isNotEmpty ? CachedNetworkImage(
              imageUrl: imageUpperServerPath,
              imageBuilder: (context, imageProvider) => Container(
                child: Container(
                  width: windowHeight * 0.3,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      )),
                ),
              )
          ) : Container()
      ),
    );
  }

  _body(){
    List<Widget> list = [];

    list.add(Container(
        width: windowWidth,
        margin: EdgeInsets.only(left: 10, right: 10),
        child: Card50a()
    ));

    list.add(SizedBox(height: 20,));

    List<Widget> list2 = [];
    if (_mainModel.currentProvider.phone.isNotEmpty)
      list2.add(InkWell(
          onTap: () {
            callMobile(_mainModel.currentProvider.phone);
          }, // needed
          child: UnconstrainedBox(
            child: Container(
                width: 40,
                height: 40,
                child: Image.asset("assets/phone.png",
                    fit: BoxFit.contain
                )
            ),
          )),);

    if (_mainModel.currentProvider.www.isNotEmpty)
      list2.add(InkWell(
          onTap: () {
            openUrl(_mainModel.currentProvider.www);
          }, // needed
          child: UnconstrainedBox(
            child: Container(
                width: 40,
                height: 40,
                child: Image.asset("assets/www.png",
                    fit: BoxFit.contain
                )
            ),
          )),);

    if (_mainModel.currentProvider.instagram.isNotEmpty)
      list2.add(InkWell(
          onTap: () {
            openUrl(_mainModel.currentProvider.instagram);
          }, // needed
          child: UnconstrainedBox(
            child: Container(
                width: 40,
                height: 40,
                child: Image.asset("assets/insta.png",
                    fit: BoxFit.contain
                )
            ),
          )),);

    if (_mainModel.currentProvider.telegram.isNotEmpty)
      list2.add(InkWell(
          onTap: () {
            openUrl(_mainModel.currentProvider.telegram);
          }, // needed
          child: UnconstrainedBox(
            child: Container(
                width: 40,
                height: 40,
                child: Image.asset("assets/tg.png",
                    fit: BoxFit.contain
                )
            ),
          )),);

    if (list2.isNotEmpty)
      list.add(Container(
        margin: EdgeInsets.only(left: 10, right: 10),
        height: 40,
        width: windowWidth - 20,
        child: Wrap(
          alignment: WrapAlignment.center,
          runSpacing: 20,
          spacing: 20,
          children: list2,
        ),
      ));

    list.add(SizedBox(height: 20,),);

    if (_mainModel.currentProvider.descTitle.isNotEmpty)
      list.add(Container(
          padding: EdgeInsets.only(left: 20, right: 20),
          color: (darkMode) ? Colors.black : Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(getTextByLocale(_mainModel.currentProvider.descTitle),
                style: theme.style16W800, textAlign: TextAlign.start,),   // "Description",
              Divider(color: (darkMode) ? Colors.white : Colors.black),
              SizedBox(height: 5,),
              Text(getTextByLocale(_mainModel.currentProvider.desc), style: theme.style14W400),
              SizedBox(height: 5,),
              Divider(color: (darkMode) ? Colors.white : Colors.black),
            ],
          )
      ));

    list.add(SizedBox(height: 20,),);

    var index = 0;
    for (var item in _mainModel.currentProvider.workTime){
      if (item.weekend)
        continue;
      list.add(Container(
          margin: EdgeInsets.only(left: 20, right: 20),
          child: Row(
            children: [
              Expanded(child: Text(strings.get(123+index), style: theme.style14W800,),),
              Text(item.openTime, style: theme.style14W400),
              Text("-"),
              Text(item.closeTime, style: theme.style14W400),
            ],
          )));
      list.add(SizedBox(height: 5,));
      index++;
    }
    list.add(SizedBox(height: 20,));

    list.add(Container(
        color: (darkMode) ? blackColorTitleBkg : colorBackground,
        padding: EdgeInsets.only(left: 20, right: 20),
        child: Row(
          children: [
            Expanded(child: Text(strings.get(100), // "Galleries",
              style: theme.style14W800,)),
            Container(
                width: windowSize/2,
                height: windowSize/2,
                child: theme.providerGLogoAsset ? Image.asset("assets/ondemands/ondemand20.png", fit: BoxFit.contain) :
                CachedNetworkImage(
                    imageUrl: theme.providerGLogo,
                    imageBuilder: (context, imageProvider) => Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.contain,
                        ),
                      ),
                    )
                ),
                // Image.asset("assets/ondemands/ondemand20.png",
                //     fit: BoxFit.contain
                // )
            ),
          ],
        )));

    list.add(SizedBox(height: 10,));

    if (_mainModel.currentProvider.gallery.isNotEmpty)
      list.add(Container(
        margin: EdgeInsets.only(left: 20, right: 20),
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _mainModel.currentProvider.gallery.map((e){
            var _tag = UniqueKey().toString();
            return InkWell(
                onTap: (){
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GalleryScreen(item: e, gallery: _mainModel.currentProvider.gallery, tag: _tag),
                      )
                  );
                },
                child: Hero(
                    tag: _tag,
                    child: Container(
                        width: windowSize/3-20,
                        height: windowSize/3-20,
                        child: Image.network(e.serverPath, fit: BoxFit.cover)
                      // (e.name != null) ?
                      // Image.asset(e.name!, fit: BoxFit.cover) :
                      // Image.memory(e.image!, fit: BoxFit.cover)
                      // )
                    )));
          }).toList(),
        ),
      ));

    list.add(SizedBox(height: 20,));

    // list.add(Container(
    //     color: (darkMode) ? blackColorTitleBkg : colorBackground,
    //     padding: EdgeInsets.only(left: 20, right: 20),
    //     child: Row(
    //       children: [
    //         Expanded(child: Column(
    //           children: [
    //             Text(strings.get(101), // "Reviews & Ratings"
    //               style: theme.style14W800,),
    //             SizedBox(height: 20,),
    //             Row(children: [
    //               card51(4, Colors.orange, 20),
    //               Text("4.0", style: theme.style12W600Orange, textAlign: TextAlign.center,),
    //               SizedBox(width: 5,),
    //               Text("(1)", style: theme.style14W800, textAlign: TextAlign.center,),
    //             ],),
    //           ],
    //         )),
    //         Container(
    //             width: windowSize*0.4,
    //             child: Image.asset("assets/ondemands/ondemand19.png",
    //                 fit: BoxFit.contain
    //             )
    //         ),
    //       ],
    //     )));
    //
    // list.add(SizedBox(height: 10,));

    // list.add(Container(
    //     margin: EdgeInsets.only(left: 10, right: 10),
    //     child: Column(
    //       children: [
    //
    //         card47("assets/user1.jpg",
    //             "Carter Anne", theme.style16W800,
    //             "20 Dec 2021", theme.style12W600Grey,
    //             "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ",
    //             theme.style14W400,
    //             false, (darkMode) ? blackColorTitleBkg : colorBackground,
    //             ["assets/barber/1.jpg", "assets/barber/2.jpg", "assets/barber/3.jpg",],
    //             3, Colors.orange
    //         ),
    //
    //       ],
    //     )));


    list.add(SizedBox(height: 150,));
    return Container(
        child: ListView(
          padding: EdgeInsets.only(top: 0),
          children: list,
        )
    );
  }
}

