import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ondemandservice/ui/theme.dart';

import '../../strings.dart';

Widget button157(String text, Color color, String icon, Function _callback, double width, double height){
  return Stack(
    children: <Widget>[

      Container(
          width: width,
          height: height,
          margin: EdgeInsets.only(top: 20),
          child: Stack(
              children: <Widget>[

                Container(
                    decoration: BoxDecoration(
                      //color: color,
                      borderRadius: BorderRadius.circular(theme.radius),
                    ),
                    padding: EdgeInsets.only(right: 10, left: 10),

                // child: Row(
                //   children: [
                //     Expanded(child: Text(text, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white), textAlign: TextAlign.left,),
                //     ),
                //
                //     Expanded(child: Container(
                //       margin: EdgeInsets.only(left: 5, right: 5),
                //     )),
                //   ],
                // )
              ),

              ])
      ),

        Positioned.fill(
          child: Container(
            width: double.maxFinite,
              margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
              // alignment: strings.direction == TextDirection.ltr ? Alignment.centerRight : Alignment.centerLeft,
                child: Stack(
                  children: [
                    Container(
                      alignment: strings.direction == TextDirection.ltr ? Alignment.bottomRight : Alignment.bottomLeft,
                      child: icon.isNotEmpty ? CachedNetworkImage(
                          imageUrl: icon,
                          imageBuilder: (context, imageProvider) => Container(
                            width: double.maxFinite,
                            alignment: strings.direction == TextDirection.ltr ? Alignment.bottomRight : Alignment.bottomLeft,
                            // alignment: Alignment.bottomRight,
                            // child: Container(
                            //   width: height,
                            //   decoration: BoxDecoration(
                            //       image: DecorationImage(
                            //         image: imageProvider,
                            //         fit: BoxFit.contain,
                            //       )),
                            // ),
                          )
                      ) : Container(),
                      // Image.asset(icon,
                      //   fit: BoxFit.contain,
                      // )
                    ),

                    Container(
                      margin: strings.direction == TextDirection.ltr ? EdgeInsets.only(right: width*0.4, top: 20)
                          : EdgeInsets.only(left: width*0.4, top: 20),
                      alignment: strings.direction == TextDirection.ltr ? Alignment.centerLeft : Alignment.centerRight,
                      child: Text(text, style: theme.style12W800W, maxLines: 2, overflow: TextOverflow.ellipsis,
                        textAlign: strings.direction == TextDirection.ltr ? TextAlign.left : TextAlign.right,),
                    )

                  ],
                )
        )),

        Positioned.fill(
          child: Material(
              color: Colors.transparent,
              clipBehavior: Clip.hardEdge,
              shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(theme.radius) ),
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
