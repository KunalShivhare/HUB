import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ondemandservice/model/model.dart';
import '../strings.dart';
import 'package:ondemandservice/widgets/appbars/appbar1.dart';
import 'package:ondemandservice/widgets/pagin/pagin1.dart';

import 'theme.dart';

class GalleryScreen extends StatefulWidget {
  final ImageData item;
  final List<ImageData> gallery;
  final String tag;

  const GalleryScreen({Key? key, required this.item, required this.gallery, required this.tag}) : super(key: key);
  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> with TickerProviderStateMixin {

  var windowWidth;
  var windowHeight;
  double? windowSize;
  TabController? _tabController;
  var _index = 0;

  @override
  void initState() {
    _tabController = TabController(vsync: this, length: widget.gallery.length);
    _tabController!.addListener((){
      _index = _tabController!.index;
      setState(() {});
    });
    _tabController!.animateTo(widget.gallery.indexOf(widget.item));
    super.initState();
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
      backgroundColor: Colors.black,
        body: Directionality(
        textDirection: strings.direction,
        child: Stack(
          children: <Widget>[
            Container(
              height: windowHeight,
              width: windowWidth,
              child: TabBarView(
                controller: _tabController,
                children: widget.gallery.map((item) {
                  return Container(
                      child: Hero(
                        tag: UniqueKey().toString(),
                        child: Container(
                          child: CachedNetworkImage(
                            placeholder: (context, url) =>
                                UnconstrainedBox(child:
                                Container(
                                  alignment: Alignment.center,
                                  width: 40,
                                  height: 40,
                                  child: CircularProgressIndicator(backgroundColor: Colors.black, ),
                                )),
                            imageUrl: item.serverPath,
                            imageBuilder: (context, imageProvider) => Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            errorWidget: (context,url,error) => new Icon(Icons.error),
                          ),
                        ),
                      ));
                }).toList()
              ),
        ),

        Container(
          alignment: Alignment.bottomCenter,
          margin: EdgeInsets.only(bottom: 20),
          child: pagination1(_tabController!.length, _index, mainColor),
        ),

        appbar1(Colors.transparent, mainColor, "", context, () {Navigator.pop(context);})

    ])));
  }
}


