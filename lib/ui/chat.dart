import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ondemandservice/model/model.dart';
import 'package:ondemandservice/widgets/edit/edit26.dart';
import 'package:ondemandservice/widgets/loader/loader7.dart';
import '../util.dart';
import '../strings.dart';
import 'theme.dart';
import 'package:ondemandservice/widgets/cards/card41.dart';
import 'package:ondemandservice/widgets/clippath/clippath23.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  var windowWidth;
  var windowHeight;
  String _searchText = "";
  double windowSize = 0;
  ScrollController _scrollController = ScrollController();
  var _controllerSearch = TextEditingController();

  late MainModel _mainModel;

  @override
  void initState() {
    _mainModel = Provider.of<MainModel>(context,listen:false);
    _scrollController.addListener(_scrollListener);
    _init();
    super.initState();
  }

  _init() async {
    _waits(true);
    var ret = await _mainModel.getChatMessages(_redraw);
    if (ret != null)
      return messageError(context, ret);
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
    for (var item in _mainModel.customersChat)
      if (item.listen != null)
        item.listen!.cancel();
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
                            color: (darkMode) ? Colors.black : Colors.white,
                            child: FlexibleSpaceBar(
                                collapseMode: CollapseMode.pin,
                                background: _title(),
                                titlePadding: EdgeInsets.only(bottom: 10, left: 20, right: 20),
                                title: _titleSmall()
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
                      Center(child: Container(child: Loader7(color: mainColor,))),
                  ],
                ),
              ),
            ),

          ]),
      ));
  }

  _title() {
    return Container(
      color: (darkMode) ? Colors.black : Colors.white,
      height: windowHeight * 0.3,
      width: windowWidth/2,
      child: Stack(
        children: [
          Container(
            alignment: Alignment.bottomRight,
            child:
            Container(
              width: windowWidth*0.3,
              height: windowWidth*0.3,
              child: theme.chatLogoAsset ? Image.asset("assets/ondemands/ondemand21.png", fit: BoxFit.contain) :
              CachedNetworkImage(
                  imageUrl: theme.chatLogo,
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
            // Container(
            //   width: windowWidth*0.3,
            //   child: Image.asset("assets/ondemands/ondemand21.png", fit: BoxFit.cover),
            //),
            margin: EdgeInsets.only(bottom: 10, right: 20, left: 20),
          ),
        ],
      ),
    );
  }

  _titleSmall(){
    return Container(
        alignment: Alignment.bottomLeft,
        padding: EdgeInsets.only(bottom: _scroller, left: 20, right: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(strings.get(7), // "Chat",
              style: theme.style16W800,),
            SizedBox(height: 3,),
            Text(strings.get(85), // Chatting online
                style: theme.style10W600Grey),
          ],
        )
    );
  }

  _body(){
    List<Widget> list = [];

    // ignore: unnecessary_statements
    context.watch<MainModel>().customersChat;

    list.add(Container(
      margin: EdgeInsets.only(left: 15, right: 15),
      child: Edit26(
          hint: strings.get(122), /// "Search",
          color: (darkMode) ? Colors.black : Colors.white,
          style: theme.style14W400,
          radius: 10,
          icon: Icons.search,
          useAlpha: false,
          controller: _controllerSearch,
          onChangeText: (String value){
            _searchText = value;
            setState(() {
            });
          }
      ),
    ));

    list.add(SizedBox(height: 20,));

    for (var item in _mainModel.customersChat){
      print(item.lastMessage);
      if (_searchText.isNotEmpty)
        if (!item.name.toUpperCase().contains(_searchText.toUpperCase()))
            continue;
      list.add(InkWell(
        onTap: (){
          _mainModel.setChatData(item.name, item.unread, item.logoServerPath, item.id);
          _mainModel.route("chat2");
        },
          child: Container(
          margin: EdgeInsets.only(left: 10, right: 10),
              child: Card41(
              all: item.all,
              unread: item.unread,
              image: item.logoServerPath,
              text1: item.name, style1: theme.style16W800,
              text2: item.lastMessage, style2: theme.style14W600Grey,
              text3: item.lastMessageTime != null
                  ? _mainModel.localAppSettings.getDateTimeString(item.lastMessageTime!)
                  : "",
              style3: theme.style12W600Grey,
              bkgColor: (darkMode) ? Colors.black : Colors.white
          )
      )));
      list.add(SizedBox(height: 10,));
    }

    list.add(SizedBox(height: 150,));
    return Container(
        child: ListView(
          children: list,
        )
    );
  }
}

