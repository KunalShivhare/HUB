import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ondemandservice/model/model.dart';
import 'package:ondemandservice/ui/theme.dart';
import 'package:ondemandservice/widgets/appbars/appbar1.dart';
import 'package:ondemandservice/widgets/buttons/button202m.dart';
import 'package:ondemandservice/widgets/cards/card50.dart';
import 'package:ondemandservice/widgets/edit/edit26.dart';
import 'package:provider/provider.dart';

import '../strings.dart';
import '../util.dart';
import 'dialogs/filter.dart';

class SearchScreen extends StatefulWidget {
  final Function() jump;
  final Function() close;
  final Function() openDialogFilter;

  const SearchScreen({Key? key, required this.jump, required this.close,
    required this.openDialogFilter}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with TickerProviderStateMixin{

  var windowWidth;
  var windowHeight;
  late TabController _tabController;
  FocusNode _focusNode = FocusNode();
  String _searchText = "";
  var _controllerSearch = TextEditingController();
  late MainModel _mainModel;

  @override
  void initState() {
    _mainModel = Provider.of<MainModel>(context,listen:false);
    _focusNode.requestFocus();
    _tabController = TabController(vsync: this, length: 2);
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controllerSearch.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        Container(
          height: windowHeight,
          child: ListView(
            padding: EdgeInsets.only(top: 0),
            children: _searchWidgets(),
          ),
        ),
        appbar1(Colors.transparent, (darkMode) ? Colors.white : Colors.black,
            "", context, () {
              widget.close();
            }),
      ],
    );
  }

  _searchWidgets(){
    List<Widget> list = [];

    list.add(Container(
      color: darkMode ? Colors.black : Colors.white,
      height: MediaQuery.of(context).padding.top+50,
        child: Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top+10, left: 50, right: 50),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(strings.get(122), /// "Search",
                style: theme.style16W800,),
              SizedBox(height: 3,),
              Text(strings.get(94), // Find what you need
                  style: theme.style10W600Grey),
            ],
      ),
      ))
    );

    list.add(SizedBox(height: 10,));

    list.add(Container(
      margin: EdgeInsets.only(left: 10, right: 10),
      child: Row(
        children: [
          Expanded(child: Edit26(
            onSuffixIconPress: widget.close,
            suffixIcon: Icons.cancel,
            focusNode: _focusNode,
            hint: strings.get(122), /// "Search",
            color: (darkMode) ? Colors.black : Colors.white,
            style: theme.style14W400,
            radius: 10,
            useAlpha: false,
            icon: Icons.search,
            controller: _controllerSearch,
            onTap: (){
              // Future.delayed(const Duration(milliseconds: 500), () {
              //   _scrollController.jumpTo(96);
              // });
            },
            onChangeText: (String val){
              _searchText = val;
              // widget.jump();
              _redraw();
            },
          )),
          // SizedBox(width: 10,),
          IconButton(onPressed: widget.openDialogFilter, icon: Icon(Icons.filter_alt, color: mainColor,))
        ],
      ))
    );
    list.add(SizedBox(height: 10,));

    list.add(TabBar(
      indicatorColor: mainColor,
      labelColor: Colors.black,
      tabs: [
        Text(strings.get(177),     /// "Service",
            textAlign: TextAlign.center,
            style: theme.style12W600Grey
        ),
        // Text(strings.get(155),     /// "Provider",
        //     textAlign: TextAlign.center,
        //     style: theme.style12W600Grey
        // ),
        Text(strings.get(174),     // "Blog",
            textAlign: TextAlign.center,
            style: theme.style12W600Grey
        ),
      ],
      controller: _tabController,
    ),
    );

    list.add(Container(
        height: windowHeight,
        child: TabBarView(
      controller: _tabController,
      children: <Widget>[

        ListView(
          padding: EdgeInsets.only(top: 10),
          children: _getServices(),
        ),

        ListView(
          padding: EdgeInsets.only(top: 10),
          children: _getProviders(),
        ),
      ],
    )));

    return list;
  }

  _getServices(){
    List<Widget> list = [];
    User? user = FirebaseAuth.instance.currentUser;

    for (var item in (applyFilter) ? _mainModel.serviceSearch : _mainModel.service) {
      if (_searchText.isNotEmpty)
        if (!getTextByLocale(item.name).toUpperCase().contains(_searchText.toUpperCase()))
          continue;
      var _tag = UniqueKey().toString();
      list.add(InkWell(onTap: (){
          _mainModel.currentService = item;
          _mainModel.route("service");
        },
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
      list.add(SizedBox(height: 10,));
    }

    if (list.isEmpty){
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
      ),
      ));
      list.add(SizedBox(height: 10,));
      list.add(Center(child: Text(strings.get(150), style: theme.style18W800Grey,),)); /// "Not found ...",
    }

    list.add(SizedBox(height: 300,));

    return list;
  }

  _getProviders(){
    List<Widget> list = [];

    for (var item in _mainModel.provider) {
      if (_searchText.isNotEmpty)
        if (!getTextByLocale(item.name).toUpperCase().contains(_searchText.toUpperCase()))
          continue;
      list.add(Container(
          color: (darkMode) ? Colors.black : Colors.white,
          padding: EdgeInsets.only(bottom: 5, top: 5),
          child: button202m(item,
            windowWidth*0.26, _mainModel, (){
              _mainModel.currentProvider = item;
              _mainModel.route("provider");
            },))
      );
      list.add(SizedBox(height: 1,));
    }

    if (list.isEmpty){
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
      ),
      ));
      list.add(SizedBox(height: 10,));
      list.add(Center(child: Text(strings.get(150), style: theme.style18W800Grey,),)); /// "Not found ...",
    }

    list.add(SizedBox(height: 300,));

    return list;
  }

  _redraw(){
    if (mounted)
      setState(() {
      });
  }
}