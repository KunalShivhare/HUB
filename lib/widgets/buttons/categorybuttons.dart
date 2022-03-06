import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ondemandservice/ui/theme.dart';
import '../../strings.dart';

categorybuttons(String text, Color color, String icon, Function _callback, double width, double height){

  return Stack(
    children: <Widget>[

      Container(
          margin: EdgeInsets.all(5),
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: (darkMode) ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(theme.radius),
          ),
          child: Column(
            children: [
              Expanded(
                  child: ClipRRect(
                    borderRadius: new BorderRadius.only(topLeft: Radius.circular(theme.radius), topRight: Radius.circular(theme.radius)),
                    child: Container(
                      width: width,
                      height: height,
                      child: icon.isNotEmpty ? CachedNetworkImage(
                          imageUrl: icon,
                          imageBuilder: (context, imageProvider) => Container(
                            width: double.maxFinite,
                            alignment: strings.direction == TextDirection.ltr ? Alignment.bottomRight : Alignment.bottomLeft,
                            // alignment: Alignment.bottomRight,
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
                    ),
                  )),

              Container(
                margin: EdgeInsets.only(left: 10, right: 10, top: 3, bottom: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(text, style: theme.style12W800, textAlign: TextAlign.center,),
                  ],
                ),
              ),
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
