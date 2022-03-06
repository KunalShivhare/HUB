
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ondemandservice/ui/theme.dart';

import '../../strings.dart';

class Card43 extends StatelessWidget {
  final String image;
  final String text1;
  final String text2;
  final String text3;
  final String date;
  final String dateCreating;
  final String bookingId;
  final bool shadow;
  final Color bkgColor;
  final double imageRadius;
  final double padding;
  final Widget icon;

  const Card43({Key? key, required this.image, required this.text1, required this.text2,
    required this.text3, required this.date, required this.icon,
    this.shadow = false, this.bkgColor = Colors.white, this.imageRadius = 50,
    required this.dateCreating, required this.bookingId,
    this.padding = 5, }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: bkgColor,
          borderRadius: new BorderRadius.circular(theme.radius),
          boxShadow: (shadow) ? [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 3,
              blurRadius: 5,
              offset: Offset(3, 3),
            ),
          ] : null,
        ),
        child: Container(
          padding: EdgeInsets.only(top: 5, bottom: 5, left: 10),

          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(text1, style: theme.style14W800,),
                      SizedBox(height: 5,),
                      Text(text2, style: theme.style12W600Grey,),
                      SizedBox(height: 5,),
                      Row(children: [
                        Text(strings.get(231), style: theme.style12W800), /// Time creation
                        SizedBox(width: 10,),
                        Expanded(child: Text(dateCreating, style: theme.style12W400, overflow: TextOverflow.ellipsis))
                      ],),
                      SizedBox(height: 5,),
                      Row(children: [
                        Text(strings.get(232), style: theme.style12W800), /// "Booking ID",
                        SizedBox(width: 10,),
                        Expanded(child: Text(bookingId, style: theme.style12W400, overflow: TextOverflow.ellipsis,)),
                      ],),
                      SizedBox(height: 15,),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          icon,
                          SizedBox(width: 5,),
                          Text(text3, style: theme.style12W400,),
                          SizedBox(width: 5,),
                          Container(
                            height: 15,
                              alignment: Alignment.center,
                              child: Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          )),
                          SizedBox(width: 5,),
                          Flexible(child: FittedBox(child: Text(date, style: theme.style13W800Blue))),
                        ],
                      )
                    ],)),
              SizedBox(width: 20,),
              Container(
                height: 60,
                width: 60,
                //padding: EdgeInsets.only(left: 10, right: 10),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(imageRadius),
                    child: image.isNotEmpty ? CachedNetworkImage(
                                imageUrl: image,
                                imageBuilder: (context, imageProvider) => Container(
                                  width: double.maxFinite,
                                  alignment: Alignment.bottomRight,
                                  child: Container(
                                    //width: height,
                                    decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.cover,
                                        )),
                                  ),
                                )
                            ) : Container(),
                    ),
              ),
              SizedBox(width: 10,),
            ],
          ),

        ));
  }
}
