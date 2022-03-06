import 'package:flutter/material.dart';
import 'package:ondemandservice/ui/theme.dart';

class Edit26 extends StatefulWidget {
  final String hint;
  final Function(String)? onChangeText;
  final Function()? onSuffixIconPress;
  final Function()? onTap;
  final TextEditingController controller;
  final TextInputType type;
  final Color color;
  final Color borderColor;
  final IconData icon;
  final IconData? suffixIcon;
  final TextStyle style;
  final double radius;
  final bool useAlpha;
  final FocusNode? focusNode;

  Edit26({this.hint = "", required this.controller, this.type = TextInputType.text, this.color = Colors.black, this.radius = 0,
    this.onChangeText, required this.icon, this.borderColor = Colors.transparent, this.style = const TextStyle(),
    this.useAlpha = true, this.onTap, this.suffixIcon, this.onSuffixIconPress, this.focusNode});

  @override
  _Edit26State createState() => _Edit26State();
}

class _Edit26State extends State<Edit26> {

  @override
  Widget build(BuildContext context) {

    return Container(
        height: 40,
        padding: EdgeInsets.only(left: 10, right: 10),
        decoration: new BoxDecoration(
          shape: BoxShape.rectangle,
          color: (widget.useAlpha) ? widget.color.withAlpha(60) : widget.color,
          border: Border.all(color: widget.borderColor),
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      child: Center(child: TextFormField(
        focusNode: widget.focusNode,
        obscureText: false,
        cursorColor: widget.style.color,
        keyboardType: widget.type,
        controller: widget.controller,
        onTap: () async {
          if (widget.onTap != null)
            widget.onTap!();
        },
        onChanged: (String value) async {
          if (widget.onChangeText != null)
            widget.onChangeText!(value);
        },
        textAlignVertical: TextAlignVertical.center,
        style: widget.style,
        decoration: new InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(
            widget.icon,
            color: widget.style.color,
          ),
          suffixIcon: IconButton(icon: Icon(
            widget.suffixIcon,
            color: mainColor,
          ), onPressed: () {
            if (widget.onSuffixIconPress != null)
              widget.onSuffixIconPress!();
            },),
          hintText: widget.hint,
          hintStyle: widget.style,
        ),
      ),
    ));
  }
}