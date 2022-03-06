import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ondemandservice/model/blog.dart';
import 'package:ondemandservice/model/category.dart';
import 'package:ondemandservice/model/localSettings.dart';
import 'package:ondemandservice/model/model.dart';
import 'package:ondemandservice/model/service.dart';
import 'package:ondemandservice/ui/search.dart';
import 'package:ondemandservice/widgets/buttons/button202Blog.dart';
import 'package:ondemandservice/widgets/buttons/button202m.dart';
import 'package:ondemandservice/widgets/buttons/categorybuttons.dart';
import 'package:ondemandservice/widgets/cards/card50.dart';
import 'package:ondemandservice/widgets/ibanner.dart';
import 'package:ondemandservice/widgets/loader/loader7.dart';
import '../strings.dart';
import '../util.dart';
import 'elements/address.dart';
import 'theme.dart';
import 'package:ondemandservice/widgets/buttons/button157.dart';
import 'package:ondemandservice/widgets/buttons/button202.dart';
import 'package:ondemandservice/widgets/clippath/clippath23.dart';
import 'package:ondemandservice/widgets/edit/edit26.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  final Function() openDialogFilter;

  const HomeScreen({Key? key, required this.openDialogFilter}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  var windowWidth;
  var windowHeight;
  double windowSize = 0;
  ScrollController _scrollController = ScrollController();
  var _controllerSearch = TextEditingController();

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<
      RefreshIndicatorState>();
  late MainModel _mainModel;

  @override
  void initState() {
    _mainModel = Provider.of<MainModel>(context, listen: false);
    _scrollController.addListener(_scrollListener);
    comboBoxInitAddress(_mainModel);
    _mainModel.checksubscriptionend();
    super.initState();
  }

  double _scroller = 20;

  _scrollListener() {
    var _scrollPosition = _scrollController.position.pixels;
    _scroller = 20 - (_scrollPosition / (windowHeight * 0.1 / 20));
    if (_scroller < 0)
      _scroller = 0;
    setState(() {});
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

              if (_mainModel.searchActivate)
                SearchScreen(
                  jump: () {
                    _scrollController.jumpTo(96);
                  }, close: () {
                  _mainModel.searchActivate = false;
                  _redraw();
                },
                  openDialogFilter: widget.openDialogFilter,
                ),

              if (!_mainModel.searchActivate)
                NestedScrollView(
                  controller: _scrollController,
                  headerSliverBuilder: (BuildContext context,
                      bool innerBoxIsScrolled) {
                    return [
                      SliverAppBar(
                          expandedHeight: windowHeight * 0.2,
                          automaticallyImplyLeading: false,
                          pinned: true,
                          elevation: 0,
                          backgroundColor: Colors.transparent,
                          flexibleSpace: ClipPath(
                            clipper: ClipPathClass23(
                                (_scroller < 5) ? 5 : _scroller),
                            child: Container(
                                color: (darkMode) ? Colors.black : Colors.white,
                                child: Stack(
                                  children: [
                                    FlexibleSpaceBar(
                                        collapseMode: CollapseMode.pin,
                                        background: _title(),
                                        titlePadding: EdgeInsets.only(
                                            bottom: 10, left: 20, right: 20),
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
                      child: Stack(
                        children: [
                          _body(),
                          if (_wait)
                            Center(child: Container(
                                child: Loader7(color: mainColor,))),
                        ],
                      )),
                ),

              ]),
        ));
  }

  _title() {
    return Container(
      color: (darkMode) ? Colors.black : Colors.white,
      height: windowHeight * 0.3,
      width: windowWidth / 2,
      child: Stack(
        children: [
          Container(
            alignment: Alignment.bottomRight,
            child: Container(
              width: windowWidth * 0.3,
              height: windowWidth * 0.3,
              child: theme.homeLogoAsset ? Image.asset(
                  "assets/ondemands/ondemand23.png", fit: BoxFit.contain) :
              CachedNetworkImage(
                  imageUrl: theme.homeLogo,
                  imageBuilder: (context, imageProvider) =>
                      Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.contain,
                          ),
                        ),
                      )
              ),
              //Image.asset("assets/ondemands/ondemand23.png", fit: BoxFit.cover),
            ),
            margin: EdgeInsets.only(bottom: 10, right: 20, left: 20),
          ),
        ],
      ),
    );
  }

  _titleSmall() {
    return Container(
        alignment: Alignment.bottomLeft,
        padding: EdgeInsets.only(
            bottom: _scroller, left: 20, right: 20, top: 25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              !_mainModel.searchActivate ? strings.get(93) : strings.get(122), /// "Home services", // "Search",
              style: theme.style16W800,),
            SizedBox(height: 3,),
            Text(strings.get(94), // Find what you need
                style: theme.style10W600Grey),
          ],
        )
    );
  }

  _body() {
    List<Widget> list = [];

    //
    // address
    //
    list.add(comboBoxAddress(_mainModel));

    for (var item in _mainModel.localAppSettings.customerAppElements) {
      //
      // search
      //
      if (item == "search") {
        list.add(Container(
          margin: EdgeInsets.only(left: 10, right: 10),
          child: Edit26(
            hint: strings.get(95),  /// "Search service",
            color: (darkMode) ? Colors.black : Colors.white,
            style: theme.style14W400,
            radius: 10,
            useAlpha: false,
            icon: Icons.search,
            controller: _controllerSearch,
            onTap: () {
              _mainModel.searchActivate = true;
              _redraw();
              Future.delayed(const Duration(milliseconds: 500), () {
                _scrollController.jumpTo(96);
              });
            },
            onChangeText: (String val) {
              //_searchText = val;
              _scrollController.jumpTo(96);
            },
          ),),
        );
        list.add(SizedBox(height: 10,));
      }

      //
      // Providers
      //
      // if (item == "providers" && blog.isNotEmpty) {
      //   list.add(Container(
      //       margin: EdgeInsets.only(left: 20, right: 20),
      //       child: Row(
      //         children: [
      //           Expanded(child: Text(strings.get(224), style: theme.style14W800,)), /// "Providers",
      //           InkWell(
      //               onTap: () {
      //                 _mainModel.route("providers_all");
      //               },
      //               child: Container(
      //                   padding: EdgeInsets.all(5),
      //                   child: Text(strings.get(175), style: theme.style12W600Blue,) /// View all
      //               ))
      //         ],
      //       )));
      //   list.add(SizedBox(height: 10,));
      //   _addProviders(list);
      //   list.add(SizedBox(height: 10,));
      // }

      //
      // blog
      //
      // if (item == "blog" && blog.isNotEmpty) {
      //   list.add(Container(
      //       margin: EdgeInsets.only(left: 20, right: 20),
      //       child: Row(
      //         children: [
      //           Expanded(
      //               child: Text(strings.get(174), style: theme.style14W800,)), /// "Blog",
      //           InkWell(
      //               onTap: () {
      //                 _mainModel.route("blog_all");
      //               },
      //               child: Container(
      //                   padding: EdgeInsets.all(5),
      //                   child: Text(
      //                     strings.get(175), style: theme.style12W600Blue,) /// View all
      //               ))
      //         ],
      //       )));
      //   _addBlog(list);
      //   list.add(SizedBox(height: 10,));
      // }

      //
      // banner
      //
      if (item == "banner") {
        if (_mainModel.banner.banners.isNotEmpty)
          list.add(IBanner(
            _mainModel.banner.banners,
            width: windowWidth,
            // * 0.95,
            height: windowWidth * 0.5,
            // * 0.95*0.6,
            colorActive: mainColor,
            colorProgressBar: mainColor,
            radius: 10,
            shadow: 0,
            style: theme.style16W400,
            callback: _openBanner,
            seconds: 3,
          ));
        list.add(SizedBox(height: 10,));
      }

      //
      // category
      //
      if (item == "category") {
        List<Widget> lis=[];

        lis.add(Container(
            margin: EdgeInsets.only(left: 10, right: 10),
            child: Wrap(
             // spacing: 5,
              //runSpacing: 10,
              children: _mainModel.category.map((e) {
                // if (_searchText.isNotEmpty)
                //   if (!getTextByLocale(e.name).toUpperCase().contains(_searchText.toUpperCase()))
                //     return Container();
                var _tag = UniqueKey().toString();
                return Hero(
                      tag: _tag,
                      child: Container(
                      width: windowSize*0.3,
                        height: windowHeight,
                        child:categorybuttons(
                          getTextByLocale(e.name),
                          e.color,
                          e.serverPath, () {
                        localSettings.categoryScreenTag = _tag;
                        localSettings.categoryData = e;
                        _mainModel.route("category");
                      },
                      windowSize / 2 - 20,
                      windowSize*0.4),),
                    );
              }).toList(),
            )));

        list.add(Container(
        height: windowSize * 0.7 * 0.6,
        child: ListView(
        scrollDirection: Axis.horizontal,
        children: lis,
        ),
    ));
        //list.add(SizedBox(height: 20,));
      }

      //
      // category_details
      //
      if (item == "category_details") {
        for (var item in _mainModel.category) {
          // if (_searchText.isNotEmpty)
          //   if (!getTextByLocale(item.name).toUpperCase().contains(_searchText.toUpperCase()))
          //     continue;
          if (item.visible) {
            list.add(Container(
                child: Container(
                  //color: item.color.withAlpha(20),
                  width: windowSize - 20,
                  height: 60,
                  child: button157(
                      getTextByLocale(item.name),
                      item.color,
                      item.serverPath, () {},
                      windowSize - 20,
                      60),
                )
            )
            );
            list.add(_horizontalCategoryDetails(item));
            list.add(SizedBox(height: 10,));
          }
        }
      }

      //
      // Top Services
      //
      if (item == "top_service") {
        if (_mainModel.localAppSettings.inMainScreenServices.isNotEmpty) {

          list.add(Container(
            margin: EdgeInsets.only(left: 20, right: 20),
            child: Text(strings.get(172), style: theme.style16W800,),));  /// "Top Services",
          list.add(SizedBox(height: 10,));
          _addTopServices(list);
        }
        list.add(SizedBox(height: 20,));
      }

      //
      // favorites
      //
      if (item == "favorites") {
        if (_mainModel.userFavorites.isNotEmpty) {
          list.add(Container(
              margin: EdgeInsets.only(left: 20, right: 20),
              child: Row(
                children: [
                  Expanded(
                      child: Text(strings.get(170), style: theme.style14W800,)),

                  /// "Your Favorites",
                  InkWell(
                      onTap: () {
                        _mainModel.route("favorite");
                      },
                      child: Container(
                          padding: EdgeInsets.all(5),
                          child: Text(
                            strings.get(175), style: theme.style12W600Blue,)

                        /// View all
                      ))
                ],
              )));
          list.add(SizedBox(height: 10,));
          _listFavorites(list);
          list.add(SizedBox(height: 20,));
        }
      }
    }


    list.add(SizedBox(height: 150,));
    return Container(
        child: RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: () async {
              _waits(true);
              var ret = await _mainModel.init2();
              if (ret != null)
                messageError(context, ret);
              _waits(false);
              ret = await loadBlog(true);
              if (ret != null)
                messageError(context, ret);
              _redraw();
            },
            child: ListView(
              padding: EdgeInsets.only(top: 0),
              children: list,
            )
        ));
  }

  _listFavorites(List<Widget> list) {
    User? user = FirebaseAuth.instance.currentUser;
    var _count = 0;
    for (var item in _mainModel.service) {
      if (!_mainModel.userFavorites.contains(item.id))
        continue;
      // if (_searchText.isNotEmpty)
      //   if (!getTextByLocale(item.name).toUpperCase().contains(_searchText.toUpperCase()))
      //     continue;
      var _tag = UniqueKey().toString();
      list.add(InkWell(onTap: () {
        _openDetails(_tag, item);
      },
          child: Hero(
              tag: _tag,
              child: Container(
                  width: windowWidth,
                  margin: EdgeInsets.only(left: 10, right: 10),
                  child: Stack(
                    children: [
                      Card50(item: item,),
                      if (user != null)
                        Container(
                          margin: EdgeInsets.all(6),
                          alignment: strings.direction == TextDirection.ltr
                              ? Alignment.topRight
                              : Alignment.topLeft,
                          child: IconButton(
                            icon: _mainModel.userFavorites.contains(item.id)
                                ? Icon(Icons.favorite, size: 25,)
                                : Icon(Icons.favorite_border, size: 25,),
                            color: Colors.orange,
                            onPressed: () {
                              _mainModel.changeFavorites(item);
                            },),
                        )
                    ],
                  )
              ))));
      list.add(SizedBox(height: 10,));
      _count++;
      if (_count == 3)
        break;
    }
  }

  _addTopServices(List<Widget> list) {
    User? user = FirebaseAuth.instance.currentUser;
    for (var item in _mainModel.service) {
      if (!_mainModel.localAppSettings.inMainScreenServices.contains(item.id))
        continue;
      var _tag = UniqueKey().toString();
      list.add(InkWell(onTap: () {
        _openDetails(_tag, item);
      },
          child: Hero(
              tag: _tag,
              child: Container(
                  width: windowWidth,
                  margin: EdgeInsets.only(left: 10, right: 10),
                  child: Stack(
                    children: [
                      Card50(item: item,),
                      if (user != null)
                        Container(
                          margin: EdgeInsets.all(6),
                          alignment: strings.direction == TextDirection.ltr
                              ? Alignment.topRight
                              : Alignment.topLeft,
                          child: IconButton(
                            icon: _mainModel.userFavorites.contains(item.id)
                                ? Icon(Icons.favorite, size: 25,)
                                : Icon(Icons.favorite_border, size: 25,),
                            color: Colors.orange,
                            onPressed: () {
                              _mainModel.changeFavorites(item);
                            },),
                        )
                    ],
                  )
              ))));
      list.add(SizedBox(height: 10,));
    }
  }

  _openBanner(String id, String heroId, String image) {
    for (var item in _mainModel.banner.banners)
      if (item.id == id) {
        if (item.type == "provider") {
          for (var pr in _mainModel.provider)
            if (pr.id == item.open) {
              _mainModel.currentProvider = pr;
              _mainModel.route("provider");
            }
        }
        if (item.type == "category") {
          for (var cat in _mainModel.category)
            if (cat.id == item.open) {
              localSettings.categoryScreenTag = UniqueKey().toString();
              localSettings.categoryData = cat;
              _mainModel.route("category");
            }
        }
        if (item.type == "service") {
          for (var ser in _mainModel.service)
            if (ser.id == item.open) {
              _mainModel.currentService = ser;
              localSettings.serviceScreenTag = UniqueKey().toString();
              _mainModel.route("service");
            }
        }
      }
  }

  _openDetails(String _tag, ServiceData item) {
    _mainModel.currentService = item;
    localSettings.serviceScreenTag = _tag;
    _mainModel.route("service");
  }

  bool _wait = false;

  _waits(bool value) {
    _wait = value;
    _redraw();
  }

  _redraw() {
    if (mounted)
      setState(() {});
  }

  //
  // Services
  //
  _horizontalCategoryDetails(CategoryData parent) {
    User? user = FirebaseAuth.instance.currentUser;
    List<Widget> list = [];
    var index = 0;
    for (var item in _mainModel.service) {
      if (!item.category.contains(parent.id))
        continue;
      var _tag = UniqueKey().toString();
      list.add(Hero(
          tag: _tag,
          child: Container(
              width: windowSize * 0.4,
              child: Stack(
                children: [
                  button202(item, _mainModel,
                    windowWidth - 20, windowSize/2, () {
                      _mainModel.currentService = item;
                      localSettings.serviceScreenTag = _tag;
                      _mainModel.route("service");
                    },),

                  if (user != null)
                    Container(
                      margin: EdgeInsets.all(6),
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: _mainModel.userFavorites.contains(item.id)
                            ? Icon(Icons.favorite, size: 25,)
                            : Icon(Icons.favorite_border, size: 25,),
                        color: Colors.orange,
                        onPressed: () {
                          _mainModel.changeFavorites(item);
                        },),
                    )
                ],
              ))
      ));
      index++;
      if (index >= 10)
        break;
    }
    return Container(
      height: windowSize * 0.7 * 0.6,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: list,
      ),
    );
  }

  _addBlog(List<Widget> list) {
    list.add(SizedBox(height: 10,));
    var _count = 0;
    for (var item in blog) {
      list.add(Container(
        margin: EdgeInsets.only(left: 10, right: 10),
        child: button202Blog(item,
            (darkMode) ? Colors.black : Colors.white,
            windowWidth, windowWidth * 0.35, () {
              _mainModel.openBlog = item;
              _mainModel.route("blog_details");
            }, _mainModel),
      )
      );
      list.add(SizedBox(height: 10,));
      _count++;
      if (_count == 3)
        break;
    }
  }

  _addProviders(List<Widget> list) {
    var _count = 0;
    for (var item in _mainModel.provider) {
      list.add(Container(
          color: (darkMode) ? Colors.black : Colors.white,
          padding: EdgeInsets.only(bottom: 5, top: 5),
          child: button202m(item,
            windowWidth * 0.26, _mainModel, () {
              _mainModel.currentProvider = item;
              _mainModel.route("provider");
            },))
      );
      list.add(SizedBox(height: 1,));
      _count++;
      if (_count == 3)
        break;
    }
  }

}
