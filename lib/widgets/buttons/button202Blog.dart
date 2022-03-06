import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ondemandservice/model/blog.dart';
import 'package:ondemandservice/model/model.dart';
import 'package:ondemandservice/ui/theme.dart';
import 'package:ondemandservice/util.dart';
import 'package:timeago/timeago.dart' as timeago;

button202Blog(BlogData item,
    Color color, double width, double height,
    Function() _callback, MainModel _mainModel){
  return Stack(
    children: <Widget>[

      Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(theme.radius),
          ),
          child: Row(
            children: [
              ClipRRect(
                  borderRadius: new BorderRadius.only(topLeft: Radius.circular(theme.radius), bottomLeft: Radius.circular(theme.radius)),
                child: Container(
                  width: height,
                    height: height,
                    child: item.serverPath.isNotEmpty ? CachedNetworkImage(
                        imageUrl: item.serverPath,
                        imageBuilder: (context, imageProvider) => Container(
                          child: Container(
                            width: height,
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                )),
                          ),
                        )
                    ) : Container(),
              )),

              Expanded(
                child: Container(
                height: height,
                margin: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(getTextByLocale(item.name), style: theme.style13W800, textAlign: TextAlign.start,),
                    SizedBox(height: height*0.05,),
                    Text(timeago.format(item.time, locale: _mainModel.localAppSettings.currentServiceAppLanguage),
                        overflow: TextOverflow.ellipsis, style: theme.style10W600Grey),
                    SizedBox(height: height*0.1,),
                    Expanded(child: Text(getTextByLocale(item.desc), style: theme.style12W400,
                      textAlign: TextAlign.start, )),
                  ],
                ),
              )),


            ],
          )
      ),

        Positioned.fill(
          child: Material(
              color: Colors.transparent,
              clipBehavior: Clip.hardEdge,
              shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(theme.radius)),
              child: InkWell(
                splashColor: Colors.black.withOpacity(0.2),
                onTap: (){
                  _callback();
                }, // needed
              )),
        )

    ],
  );
}
