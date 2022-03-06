import 'package:flutter/material.dart';
import 'package:ondemandservice/ui/theme.dart';

class Edit43 extends StatefulWidget {
  final String text;
  final TextStyle textStyle;
  final String hint;
  final Function(String)? onChangeText;
  final TextEditingController controller;
  final TextInputType type;
  final Color color;
  Edit43({this.hint = "", required this.controller, this.type = TextInputType.text, this.color = Colors.grey,
    this.onChangeText, this.text = "", this.textStyle = const TextStyle()});

  @override
  _Edit43State createState() => _Edit43State();
}

class _Edit43State extends State<Edit43> {


  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    var _icon = Icons.visibility_off;
    if (!_obscure)
      _icon = Icons.visibility;

    var _sicon2 = IconButton(
      iconSize: 20,
      icon: Icon(
        _icon,
        color: widget.color,
      ),
      onPressed: () {
        setState(() {
          _obscure = !_obscure;
        });
      },
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.text, style: widget.textStyle),
        Container(
          height: 40,
          child: TextField(
            controller: widget.controller,
            onChanged: (String value) async {},
            cursorColor: Colors.black,
            style: theme.style14W400,
            cursorWidth: 1,
            obscureText: _obscure,
            textAlign: TextAlign.left,
            maxLines: 1,
            decoration: InputDecoration(
              suffixIcon: _sicon2,
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: widget.color),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: widget.color),
              ),
              border: UnderlineInputBorder(
                borderSide: BorderSide(color: widget.color),
              ),
              hintText: widget.hint,
              hintStyle: theme.style14W400Grey,
            ),
          ),
        )
      ],
    );
  }
}