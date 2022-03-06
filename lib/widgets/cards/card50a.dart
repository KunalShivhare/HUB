import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ondemandservice/model/model.dart';
import 'package:ondemandservice/ui/theme.dart';
import 'package:provider/provider.dart';

import '../../strings.dart';
import '../../util.dart';

class Card50a extends StatefulWidget {
  final String shadowText;

  Card50a({
    this.shadowText = "",
  });

  @override
  _Card50aState createState() => _Card50aState();
}

class _Card50aState extends State<Card50a>{

  late MainModel _mainModel;
  List<String> _dataCategory = [];

  @override
  void initState() {
    _mainModel = Provider.of<MainModel>(context,listen:false);
    super.initState();

    for (var item in _mainModel.category)
      if (item.select)
        _dataCategory.add(getTextByLocale(item.name));
  }

  @override
  Widget build(BuildContext context) {

    var imageUpperServerPath = _mainModel.currentProvider.logoServerPath;
    Widget image = imageUpperServerPath.isNotEmpty ? CachedNetworkImage(
        imageUrl: imageUpperServerPath,
        imageBuilder: (context, imageProvider) => Container(
          child: Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                )),
          ),
        )
    ) : Container();

    return Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: (darkMode) ? Colors.black : Colors.white,
            borderRadius: new BorderRadius.circular(theme.radius),
        ),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            ClipRRect(
                borderRadius: new BorderRadius.all(Radius.circular(theme.radius)),
                child: Stack(
                  children: [
                    Container(
                        width: 100,
                        height: 100,
                        child: image),
                    if (widget.shadowText.isNotEmpty)
                      Positioned.fill(
                          child: Container(
                            color: Colors.black.withAlpha(150),
                            child: Center(child: Text(widget.shadowText, style: theme.style12W600White,)),
                          ))
                  ],
                )),

            SizedBox(width: 10,),

            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                SizedBox(height: 10,),
                Container(
                  margin: strings.direction == TextDirection.ltr ? EdgeInsets.only(right: 20) : EdgeInsets.only(left: 20),
                    child: Text(getTextByLocale(_mainModel.currentProvider.name),
                      style: theme.style14W800, textAlign: TextAlign.start,)),
                SizedBox(height: 10,),
                Divider(color: theme.style14W800.color),
                SizedBox(height: 10,),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, color: Colors.orange, size: 15,),
                    SizedBox(width: 5,),
                    Expanded(child: Text(_mainModel.currentProvider.address, style: theme.style10W400),)
                  ],
                ),
                SizedBox(height: 10,),
                Divider(color: theme.style14W800.color),
                SizedBox(height: 10,),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _dataCategory.map((e) {
                    return Container(
                      padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: new BorderRadius.circular(theme.radius),
                      ),
                      child: Text(e, style: theme.style10W600White,),
                    );
                  }).toList(),
                ),
                SizedBox(height: 10,),
              ],
            ))

          ],
        )
    );
  }
}
