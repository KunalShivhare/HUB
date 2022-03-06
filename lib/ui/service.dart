import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ondemandservice/model/localSettings.dart';
import 'package:ondemandservice/model/model.dart';
import 'package:ondemandservice/model/service.dart';
import 'package:ondemandservice/ui/elements/widgets.dart';
import 'package:ondemandservice/util.dart';
import 'package:ondemandservice/widgets/buttons/button202a.dart';
import 'addons.dart';
import 'gallery.dart';
import '../strings.dart';
import 'theme.dart';
import 'package:ondemandservice/widgets/appbars/appbar1.dart';
import 'package:ondemandservice/widgets/buttons/button1.dart';
import 'package:ondemandservice/widgets/cards/card47.dart';
import 'package:ondemandservice/widgets/cards/card51.dart';
import 'package:ondemandservice/widgets/clippath/clippath23.dart';
import 'package:provider/provider.dart';

class ServicesScreen extends StatefulWidget {
  @override
  _ServicesScreenState createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
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
    localSettings.price=_mainModel.currentService.price.first;
    _init();
    super.initState();
  }

  _init() async {
    var ret = await _mainModel.loadReviews();
    if (ret != null)
      messageError(context, ret);
    _redraw();
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
    return Scaffold(
        backgroundColor: (darkMode) ? blackColorTitleBkg : colorBackground,
        body: Directionality(
        textDirection: strings.direction,
        child: Container(
          color: (darkMode) ? Colors.black : Colors.white,
          width: windowWidth,
          height: windowHeight,
          child: _body2(),
    )));
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
                              ),
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
              (_scroller > 5) ? "" : getTextByLocale(_mainModel.currentService.name), context, () {
                _mainModel.goBack();
          }),

          Container(
            alignment: Alignment.bottomCenter,
            child: button1a(strings.get(102), /// "Book This Service"
                theme.style16W800White,
                mainColor, (){
                  User? user = FirebaseAuth.instance.currentUser;
                  if (user == null) {
                    _mainModel.route("login");
                  }else
                    _mainModel.route("book");
                }, true),
          ),

        ]);
  }

  _title() {
    var _data = _mainModel.getTitleImage();
    return Container(
      color: (darkMode) ? blackColorTitleBkg : colorBackground,
      height: windowHeight * 0.3,
      width: windowWidth,
      child: Container(
          width: windowWidth,
          margin: EdgeInsets.only(bottom: 10),
          child: _data.serverPath.isNotEmpty ? CachedNetworkImage(
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
          ) : Container()
      )
    );
  }

  _body(){
    List<Widget> list = [];

    list.add(SizedBox(height: 20,));

    List<Widget> list3 = [];
    list3.add(rating(_mainModel.currentService.rating.toInt(), theme.serviceStarColor, 16),);
    list3.add(SizedBox(width: 5,));
    list3.add(Text(_mainModel.currentService.rating.toStringAsFixed(1),
      style: theme.style14W400, textAlign: TextAlign.center,),);
    list3.add(SizedBox(width: 20,));
    getPriceText(_mainModel.getPrice(), list3, _mainModel);
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null){
      list3.add(SizedBox(width: 10,));
      list3.add(Container(
          alignment: Alignment.topRight,
          child: IconButton(icon: _mainModel.userFavorites.contains(_mainModel.currentService.id)
                ? Icon(Icons.favorite, size: 30,)
                : Icon(Icons.favorite_border, size: 30), color: Colors.orange,
              onPressed: (){
                _mainModel.changeFavorites(_mainModel.currentService);
              }, ),
          )
      );
    }
    list.add(
        Column(
          children: [
            Text(getTextByLocale(_mainModel.currentService.name), style: theme.style14W800),    /// name
            SizedBox(height: 5,),
            Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: list3
            )
          ],
        )
    );
    list.add(SizedBox(height: 40,));

    bool yesSelect = false;
    for (var item in _mainModel.currentService.price)
      if (item.selected)
        yesSelect = true;
    if (!yesSelect){
      bool first = true;
      for (var item in _mainModel.currentService.price) {
        if (first) {
          first = false;
          item.selected = true;
          localSettings.price = item;
        }else
          item.selected = false;
      }
    }

    for (var item in _mainModel.currentService.price){
      List<Widget> list2 = [];
      list2.add((item.image.serverPath.isNotEmpty) 
          ? Container(
            width: 30,
            height: 30,
            child: Image.network(item.image.serverPath, fit: BoxFit.contain))
          : Container(width: 30, height: 30));
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
            setState(() {
            });
          },
          child: Container(
              color: (item.selected) ? Colors.grey.withAlpha(60) : Colors.transparent,
              margin: EdgeInsets.only(bottom: 8),
              padding: EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 10),
              child: Row(children: list2))
      ));
    }

    if (_mainModel.currentService.price.isNotEmpty) {
      list.add(Divider(color: Colors.grey.withAlpha(100)));
      list.add(SizedBox(height: 10,));
    }

    listAddons(list, windowWidth, _redraw, _mainModel);

    if (_mainModel.currentService.descTitle.isNotEmpty){
      list.add(Container(
          padding: EdgeInsets.only(left: 20, right: 20),
          color: (darkMode) ? Colors.black : Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(getTextByLocale(_mainModel.currentService.descTitle),
                style: theme.style14W800, textAlign: TextAlign.start,),   /// "Description",
              Divider(color: (darkMode) ? Colors.white : Colors.black),
              SizedBox(height: 5,),
              Text(getTextByLocale(_mainModel.currentService.desc), style: theme.style12W400),
              SizedBox(height: 5,),
              Divider(color: (darkMode) ? Colors.white : Colors.black),
            ],
          )
      ));
      list.add(SizedBox(height: 30,));
    }

    list.add(Container(
      margin: EdgeInsets.only(left: 20, right: 20),
      child: Row(
        children: [
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(strings.get(97),                                                 /// "Duration",
                style: theme.style13W800,),
              Text(strings.get(99),                                                 /// "This service can take up to",
                style: theme.style12W400,)
            ],
          )),
          Text("${_mainModel.currentService.duration.inMinutes} ${strings.get(98)}", style: theme.style16W800,) /// min
        ],
      ),));

    list.add(SizedBox(height: 20,),);

    if (_mainModel.currentService.providers.isNotEmpty)
      list.add(Container(
          padding: EdgeInsets.only(left: 20, right: 20),
          color: (darkMode) ? Colors.black : Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Divider(color: (darkMode) ? Colors.white : Colors.black),
              SizedBox(height: 5,),
              // Text(strings.get(155), /// "Provider",
              //   style: theme.style13W800, textAlign: TextAlign.start,),
              SizedBox(height: 5,),
            ],
          )
      ));

    // for (var item in _mainModel.currentService.providers){
    //   for (var item2 in _mainModel.provider){
    //     if (item == item2.id){
    //       list.add(Container(
    //           height: windowSize*0.9*0.45,
    //           child: button202a(getTextByLocale(item2.name),
    //             item2.imageUpperServerPath, windowWidth-20, (){
    //               _mainModel.currentProvider = item2;
    //               _mainModel.route("provider");
    //             },)));
    //       list.add(SizedBox(height: 10,));
    //     }
    //   }
    // }

    list.add(Container(
        color: (darkMode) ? blackColorTitleBkg : colorBackground,
        padding: EdgeInsets.only(left: 20, right: 20),
        child: Row(
          children: [
            Expanded(child: Text(strings.get(100), /// "Galleries",
              style: theme.style13W800,)),
            Container(
              width: windowSize*0.4,
              height: windowSize*0.3,
              child: theme.serviceGLogoAsset
                  ? Image.asset("assets/ondemands/ondemand20.png", fit: BoxFit.contain)
                  : CachedNetworkImage(
                    imageUrl: theme.serviceGLogo,
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
          ],
        )));

    list.add(SizedBox(height: 10,));

    if (_mainModel.currentService.gallery.isNotEmpty)
      list.add(Container(
        margin: EdgeInsets.only(left: 20, right: 20),
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _mainModel.currentService.gallery.map((e){
            var _tag = UniqueKey().toString();
            return InkWell(
                onTap: (){
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GalleryScreen(item: e, gallery: _mainModel.currentService.gallery, tag: _tag),
                      )
                  );
                },
                child: Hero(
                    tag: _tag,
                    child: Container(
                        width: windowSize/3-20,
                        height: windowSize/3-20,
                        child: CachedNetworkImage(
                          placeholder: (context, url) =>
                              UnconstrainedBox(child:
                              Container(
                                alignment: Alignment.center,
                                width: 40,
                                height: 40,
                                child: CircularProgressIndicator(backgroundColor: Colors.black, ),
                              )),
                          imageUrl: e.serverPath,
                          imageBuilder: (context, imageProvider) => Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          errorWidget: (context,url,error) => new Icon(Icons.error),
                        ),
                    )));
          }).toList(),
        ),
      ));

    list.add(SizedBox(height: 20,));

    if (_mainModel.reviews.isNotEmpty)
    list.add(Container(
        color: (darkMode) ? blackColorTitleBkg : colorBackground,
        padding: EdgeInsets.only(left: 20, right: 20),
        child: Row(
          children: [
            Expanded(child: Column(
              children: [
                Text(strings.get(101), /// "Reviews & Ratings"
                  style: theme.style14W800,),
                SizedBox(height: 20,),
                Row(children: [
                  rating(_mainModel.currentService.rating.toInt(), theme.serviceStarColor, 16),
                  SizedBox(width: 5,),
                  Text(_mainModel.currentService.rating.toStringAsFixed(1),
                      style: theme.style12W600StarsService, textAlign: TextAlign.center,),
                  SizedBox(width: 5,),
                  Text("(${_mainModel.currentService.count.toString()})", style: theme.style14W800, textAlign: TextAlign.center,),
                ],),
              ],
            )),
            Container(
                width: windowSize*0.4,
              height: windowSize*0.4,
              child: theme.serviceGLogoAsset ? Image.asset("assets/ondemands/ondemand19.png", fit: BoxFit.contain) :
              CachedNetworkImage(
                  imageUrl: theme.serviceGLogo,
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
          ],
        )));

    list.add(SizedBox(height: 10,));

    for (var item in _mainModel.reviews){
      list.add(Container(
          margin: EdgeInsets.only(left: 10, right: 10),
          child: card47(item.userAvatar,
              item.userName, theme.style16W800,
              _mainModel.localAppSettings.getDateTimeString(item.time), theme.style12W600Grey,
              item.text, theme.style14W400,
              false, (darkMode) ? blackColorTitleBkg : colorBackground,
              item.images,
              item.rating, theme.serviceStarColor
          ),
        ));

      list.add(SizedBox(height: 20,));
    }

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
