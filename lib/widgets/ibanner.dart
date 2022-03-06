import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ondemandservice/model/banner.dart';

// 30.12.2020

class IBanner extends StatefulWidget {
  final List<BannerData> dataPromotion;
  final double width;
//  final Color colorBackground;
  final Color colorProgressBar;
  final double height;
  final Color colorGrey;
  final Color colorActive;
  final TextStyle style;
  final double radius;
  final int shadow;
  final Function(String id, String heroId, String image) callback;
  final int seconds;
  IBanner(this.dataPromotion, {Key? key, this.width = 100, this.height = 100, this.colorGrey = const Color.fromARGB(255, 180, 180, 180),
    this.colorActive = Colors.red, this.style = const TextStyle(),
    required this.callback, this.seconds = 3, this.colorProgressBar = Colors.black,
    this.radius = 0, this.shadow = 0}) : super(key: key);

  @override
  _IBannerState createState() => _IBannerState();
}

class _IBannerState extends State<IBanner> {

  int realCountPage = 0;
  var t = 0;
  var _currentPage = 1000;

  Timer? _timer;
  void startTimer() {
    _timer = new Timer.periodic(Duration(seconds: widget.seconds),
          (Timer timer) {
              int _page = _currentPage+1;
              _controller.animateToPage(_page, duration: Duration(seconds: 1), curve: Curves.ease);
      },
    );
  }

  @override
  void dispose() {
    if (_timer != null)
      _timer!.cancel();
    super.dispose();
  }

  @override
  void initState() {
    realCountPage = widget.dataPromotion.length;
    startTimer();
    super.initState();
  }

  _getT(int itemIndex){
    if (widget.dataPromotion.length == 0)
      return;
    if (itemIndex > 1000){
      t = itemIndex-1000;
      while(t >= realCountPage){
        t -= realCountPage;
      }
    }
    if (itemIndex < 1000){
      t = 1000-itemIndex;
      var r = realCountPage;
      do{
        if (r == 0)
          r = realCountPage;
        r--;
        t--;
      }while(t > 0);
      t = r;
    }
  }

  var _controller = PageController(initialPage: 1000, keepPage: false, viewportFraction: 1);

  _sale2(BannerData item, int index){
    var _id = UniqueKey().toString();

    return InkWell(
        onTap: () {
          widget.callback(item.id, _id, item.serverImage);
    }, // needed
    child: Stack(
      children: <Widget>[
        Container(
          width: widget.width,
          height: widget.height,
          child:
          Hero(
              tag: _id,
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(widget.radius)),
                child:Container(
                child: //Image.network(item.serverImage, fit: BoxFit.cover)
                CachedNetworkImage(
                    placeholder: (context, url) =>
                        UnconstrainedBox(child:
                        Container(
                          alignment: Alignment.center,
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(),
                        )),
                    imageUrl: item.serverImage,
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
                ),
              )
          )
        ),

        // ClipRRect(
        //     borderRadius: BorderRadius.only(topLeft: Radius.circular(widget.radius), topRight: Radius.circular(widget.radius)),
        //     child:Container(
        //         height: 20,
        //         color: Colors.black.withAlpha(140),
        //         width: widget.width,
        //         child: Container(
        //             margin: EdgeInsets.only(left: 10, right: 10),
        //             child: Text(item.name, textAlign: TextAlign.start, style: widget.style,)
        //         )
        //     )),

    ],
    ));
  }

  _lines(){
    List<Widget> lines = [];
    for (int i = 0; i < realCountPage; i++){
      if (i == t)
        lines.add(Container(width: 15, height: 3,
          decoration: BoxDecoration(
            color: widget.colorActive,
            border: Border.all(color: widget.colorActive),
            borderRadius: new BorderRadius.circular(10),
          ),
        ));
      else
        lines.add(Container(width: 15, height: 3,
          decoration: BoxDecoration(
            color: widget.colorGrey,
            border: Border.all(color: widget.colorGrey),
            borderRadius: new BorderRadius.circular(10),
          ),
        ));
      lines.add(SizedBox(width: 5,),);
    }
    return lines;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(height: widget.height,
          child: PageView.builder(
            itemCount: 10000,
            onPageChanged: (int page){
              _getT(page);
              setState(() {
              });
              _currentPage = page;
            },
            controller: _controller,
            itemBuilder: (BuildContext context, int itemIndex) {
              _getT(itemIndex);
              if (t < 0 || t > realCountPage)
                return Container();
              var item = widget.dataPromotion[t];
              return Container(
                decoration: BoxDecoration(
                    borderRadius: new BorderRadius.circular(widget.radius),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withAlpha(widget.shadow),
                        spreadRadius: 2,
                        blurRadius: 2,
                        offset: Offset(2, 2), // changes position of shadow
                      ),
                    ]
                ),
                margin: EdgeInsets.all(10),
                width: widget.width, height: widget.height,
                child: _sale2(item, t),
              );
            },
          ),
        ),


        Container(
            height: widget.height,
            child:Align(
                alignment: Alignment.bottomRight,
                child: Container(
                    margin: EdgeInsets.only(bottom: 25, right: 25),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: _lines(),
                    )
                )
            )),
      ],
    );
  }
}