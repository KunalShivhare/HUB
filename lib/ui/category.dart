import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ondemandservice/model/localSettings.dart';
import 'package:ondemandservice/model/model.dart';
import 'package:ondemandservice/model/service.dart';
import '../strings.dart';
import '../util.dart';
import 'theme.dart';
import 'package:ondemandservice/widgets/appbars/appbar1.dart';
import 'package:ondemandservice/widgets/cards/card50.dart';
import 'package:ondemandservice/widgets/clippath/clippath23.dart';
import 'package:ondemandservice/widgets/edit/edit26.dart';
import 'package:provider/provider.dart';

class CategoryScreen extends StatefulWidget {
  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {

  var windowWidth;
  var windowHeight;
  double windowSize = 0;
  ScrollController _scrollController = ScrollController();
  var _controllerSearch = TextEditingController();
  String _searchText = "";
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
                            color: localSettings.categoryData.color,
                            child: Stack(
                              children: [
                                FlexibleSpaceBar(
                                    collapseMode: CollapseMode.pin,
                                    background: _title(),
                                    titlePadding: EdgeInsets.only(bottom: 10, left: 20, right: 20),
                                    title: _titleSmall()
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

            appbar1(Colors.transparent, (darkMode) ? Colors.white : Colors.black,
                "", context, () {_mainModel.goBack();})

          ]),
      ));
  }

  _title() {
    return Container(
      color: (darkMode) ? blackColorTitleBkg : colorBackground,
      height: windowHeight * 0.3,
      width: windowWidth,
      child: Stack(
        children: [
          Hero(
            tag: localSettings.categoryScreenTag,
            child: Container(
                color: localSettings.categoryData.color,
                alignment: Alignment.bottomRight,
                child: Container(
                  width: windowWidth*0.3,
                  margin: EdgeInsets.only(bottom: 10),
                  child: localSettings.categoryData.serverPath.isNotEmpty ? CachedNetworkImage(
                      imageUrl: localSettings.categoryData.serverPath,
                      imageBuilder: (context, imageProvider) => Container(
                        width: double.maxFinite,
                        alignment: Alignment.bottomRight,
                        child: Container(
                          //width: height,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.contain,
                              )),
                        ),
                      )
                  ) : Container(),

                  //Image.asset(widget.data.image, fit: BoxFit.cover),
                ))),
        ],
      ),
    );
  }

  _titleSmall(){
    return Container(
        alignment: Alignment.bottomLeft,
        padding: EdgeInsets.only(bottom: _scroller, left: 20, right: 20, top: 25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(getTextByLocale(localSettings.categoryData.name),
              style: theme.style16W800,),
            SizedBox(height: 10,),
          ],
        )
    );
  }

  _body(){
    List<Widget> list = [];

    list.add(Container(
      margin: EdgeInsets.only(left: 20, right: 20),
      child: Edit26(
        hint: strings.get(95), /// "Search service",
        color: (darkMode) ? Colors.black : Colors.white,
        style: theme.style14W400,
        radius: 10,
        useAlpha: false,
        icon: Icons.search,
        controller: _controllerSearch,
        onChangeText: (String val){
            _scrollController.jumpTo(96);
            _searchText = val;
        },
        onTap: (){
          Future.delayed(const Duration(milliseconds: 500), () {
            _scrollController.jumpTo(96);
          });
        },
      ),),
    );

    User? user = FirebaseAuth.instance.currentUser;
    list.add(SizedBox(height: 20,));

    for (var item in _mainModel.service) {
      if (!item.category.contains(localSettings.categoryData.id))
        continue;
      if (_searchText.isNotEmpty)
        if (!getTextByLocale(item.name).toUpperCase().contains(_searchText.toUpperCase()))
          continue;

      var _tag = UniqueKey().toString();
      list.add(InkWell(onTap: (){_openDetails(_tag, item);},
          child: Hero(
              tag: _tag,
              child: Container(
                  width: windowWidth,
                  margin: EdgeInsets.only(left: 10, right: 10),
                  child: Stack(
                    children: [
                      Card50(item: item),
                      if (user != null)
                        Container(
                          margin: EdgeInsets.all(6),
                          alignment: strings.direction == TextDirection.ltr ? Alignment.topRight : Alignment.topLeft,
                          child: IconButton(icon: _mainModel.userFavorites.contains(item.id)
                              ? Icon(Icons.favorite, size: 25,)
                              : Icon(Icons.favorite_border, size: 25,), color: Colors.orange,
                            onPressed: (){_mainModel.changeFavorites(item);}, ),
                        )
                ],
            )
      ))));

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

  _openDetails(String _tag, ServiceData item){
    // localSettings.callbackStack1 = "category";
    _mainModel.currentService = item;
    localSettings.serviceScreenTag = _tag;
    _mainModel.route("service");
  }
}
