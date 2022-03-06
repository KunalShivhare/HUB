import 'package:flutter/material.dart';
import 'package:ondemandservice/ui/theme.dart';

button2(String text, Function _callback, {bool enable = true}){
  return Stack(
    children: <Widget>[
      Container(
          width: double.maxFinite,
          padding: EdgeInsets.only(top: 10, bottom: 10),
          decoration: BoxDecoration(
            color: (enable) ? mainColor : Colors.grey.withOpacity(0.5),
            borderRadius: BorderRadius.circular(theme.radius),
          ),
          child: Text(text, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis,)
      ),
      if (enable)
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

button2b(String text, Function _callback, {bool enable = true}){
  return Stack(
    children: <Widget>[
      Container(
          padding: EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
          decoration: BoxDecoration(
            color: (enable) ? mainColor : Colors.grey.withOpacity(0.5),
            borderRadius: BorderRadius.circular(theme.radius),
          ),
          child: Stack(
            children: [
              Text(text, style: theme.style12W600White, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis,),
            ],
          )

      ),

      if (enable)
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

button2s(String text, TextStyle style, Color color, double _radius, Function _callback, bool enable){
  return Stack(
    children: <Widget>[
      Container(
          width: double.maxFinite,
          padding: EdgeInsets.only(top: 10, bottom: 10),
          decoration: BoxDecoration(
            color: (enable) ? color : Colors.grey.withOpacity(0.5),
            borderRadius: BorderRadius.circular(_radius),
          ),
          child: Text(text, style: style, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis,)
      ),
      if (enable)
        Positioned.fill(
          child: Material(
              color: Colors.transparent,
              clipBehavior: Clip.hardEdge,
              shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(_radius) ),
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


button2sg(String text, TextStyle style, Color color, double _radius, Function _callback, bool enable, Color colorBkg){
  return Stack(
    children: <Widget>[
      Container(
          width: double.maxFinite,
          padding: EdgeInsets.only(top: 10, bottom: 10),
          decoration: BoxDecoration(
            color: colorBkg,
            border: Border.all(color: color, width: 2),
            borderRadius: BorderRadius.circular(_radius),
          ),
          child: Text(text, style: style, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis,)
      ),
      if (enable)
        Positioned.fill(
          child: Material(
              color: Colors.transparent,
              clipBehavior: Clip.hardEdge,
              shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(_radius) ),
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
