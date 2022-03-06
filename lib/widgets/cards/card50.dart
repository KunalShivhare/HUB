import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ondemandservice/model/model.dart';
import 'package:ondemandservice/model/service.dart';
import 'package:ondemandservice/ui/theme.dart';
import 'package:provider/provider.dart';

import '../../strings.dart';
import '../../util.dart';
import 'card51.dart';

class Card50 extends StatefulWidget {
  final ServiceData item;
  final String shadowText;

  Card50({
    this.shadowText = "",
    required this.item,
  });

  @override
  _Card50State createState() => _Card50State();
}

class _Card50State extends State<Card50>{

  late MainModel _mainModel;

  @override
  void initState() {
    _mainModel = Provider.of<MainModel>(context,listen:false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    Widget image = widget.item.gallery.isNotEmpty ? CachedNetworkImage(
        imageUrl: widget.item.gallery[0].serverPath,
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
                  margin: strings.direction == TextDirection.ltr ? EdgeInsets.only(right: 30) : EdgeInsets.only(left: 30),
                    child: Text(getTextByLocale(widget.item.name), style: theme.style14W800, textAlign: TextAlign.start,)),
                SizedBox(height: 4,),
                Text(_mainModel.getStringDistanceByProviderId(widget.item.providers[0]),
                  style: theme.style10W600Grey, textAlign: TextAlign.start,),
                SizedBox(height: 2,),
                Divider(color: theme.style14W800.color),
                Row(children: [
                  rating(widget.item.rating.toInt(), theme.categoryStarColor, 16),
                  Text(widget.item.rating.toStringAsFixed(1), style: theme.style12W600StarsCategory, textAlign: TextAlign.center,),
                  SizedBox(width: 5,),
                  Text("(${widget.item.count.toString()})", style: theme.style12W800, textAlign: TextAlign.center,),

                  Expanded(child: Text(_mainModel.localAppSettings.getServiceMinPrice(widget.item), style: theme.style18W800Orange, textAlign: TextAlign.end, maxLines: 1,)),
                ],),

                SizedBox(height: 5,),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, color: theme.categoryStarColor, size: 15,),
                    SizedBox(width: 5,),
                    Expanded(child: Text(_mainModel.getProviderAddress(widget.item.providers.isNotEmpty
                        ? widget.item.providers[0] : ""), style: theme.style10W400),)
                  ],
                ),
                SizedBox(height: 5,),
                Divider(color: theme.style14W800.color),
                SizedBox(height: 5,),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _mainModel.getServiceCategories(widget.item.category).map((e) {
                    return Container(
                      padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                      decoration: BoxDecoration(
                        color: theme.categoryBoardColor,
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
