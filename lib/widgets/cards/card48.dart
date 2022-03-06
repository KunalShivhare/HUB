import 'package:flutter/material.dart';

class Card48 extends StatefulWidget {
  final Color color;
  final Color borderColor;

  final String text;
  final TextStyle? style;

  final String text2;
  final TextStyle? style2;

  final String text3;
  final TextStyle? style3;

  final bool shadow;
  final double radius;
  final EdgeInsetsGeometry? padding;

  final Color iconColor;
  final Function() callback;

  Card48({this.color = Colors.white, this.borderColor = Colors.white,
    this.text = "", this.text2 = "", this.text3 = "", this.style3,
    this.shadow = true, this.style, this.style2,
    this.radius = 0.0, this.padding, this.iconColor = Colors.black, required this.callback,
  });

  @override
  _Card48State createState() => _Card48State();
}

class _Card48State extends State<Card48>{

  @override
  Widget build(BuildContext context) {

    return InkWell(
        child: Container(
          padding: (widget.padding == null) ? EdgeInsets.all(10) : widget.padding,
          decoration: BoxDecoration(
              color: widget.color,
              borderRadius: new BorderRadius.circular(widget.radius),
              border: Border.all(color: widget.borderColor),
              boxShadow: (widget.shadow) ? [
               BoxShadow(
                 color: Colors.grey.withAlpha(50),
                 spreadRadius: 2,
                 blurRadius: 2,
                 offset: Offset(2, 2), // changes position of shadow
               ),
             ] : null
          ),

          child: Column(
              children: [

                  Row(
                    children: <Widget>[
                      Expanded(child: Text(widget.text, style: widget.style,)),
                      IconButton(onPressed: widget.callback, icon: Icon(Icons.delete, color: widget.style!.color))
                    ],
                  ),

                  SizedBox(height: 10,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(child: Text(widget.text3, style: widget.style3,)),
                      Text(widget.text2, style: widget.style2, overflow: TextOverflow.ellipsis,)
                    ],
                  )


              ],),

          ),
        );
  }

}