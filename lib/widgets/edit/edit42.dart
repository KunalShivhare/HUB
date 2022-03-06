import 'package:flutter/material.dart';
import 'package:ondemandservice/ui/theme.dart';

edit42(String text, TextEditingController _controller,
    String _hint, {TextInputType type = TextInputType.text}) {
  bool _obscure = false;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(text, style: theme.style12W400),
      Container(
        height: 40,
        child: TextField(
          controller: _controller,
          onChanged: (String value) async {
          },
          cursorColor: Colors.black,
          style: theme.style14W400,
          cursorWidth: 1,
          keyboardType: type,
          obscureText: _obscure,
          textAlign: TextAlign.left,
          maxLines: 1,
          decoration: InputDecoration(
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              border: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              hintText: _hint,
              hintStyle: theme.style14W400Grey,
          ),
        ),
      )
    ],
  );
}

edit42Listener(String text, TextEditingController _controller,
    String _hint, Function(String) _callback){
  bool _obscure = false;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(text, style: theme.style12W600Grey),
      Container(
        height: 40,
        child: TextField(
          controller: _controller,
          onChanged: (String value) async {
            _callback(value);
          },
          cursorColor: Colors.black,
          style: theme.style14W400,
          cursorWidth: 1,
          obscureText: _obscure,
          textAlign: TextAlign.left,
          maxLines: 1,
          decoration: InputDecoration(
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            hintText: _hint,
            hintStyle: theme.style12W600Grey,
          ),
        ),
      )
    ],
  );
}

edit42Phone(String text, TextStyle _extStyle, TextEditingController _controller,
    String _hint, TextStyle _editStyle, Color color, bool enable){
  bool _obscure = false;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(text, style: _extStyle),
      Container(
        height: 40,
        child: TextField(
          controller: _controller,
          onChanged: (String value) async {
          },
          enabled: enable,
          cursorColor: Colors.black,
          style: _editStyle,
          cursorWidth: 1,
          keyboardType: TextInputType.phone,
          obscureText: _obscure,
          textAlign: TextAlign.left,
          maxLines: 1,
          decoration: InputDecoration(
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: color),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: color),
            ),
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: color),
            ),
            hintText: _hint,
            hintStyle: _editStyle,
          ),
        ),
      )
    ],
  );
}

edit42Numbers(String text, TextStyle _extStyle, TextEditingController _controller,
    String _hint, TextStyle _editStyle, Color color){
  bool _obscure = false;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(text, style: _extStyle),
      Container(
        height: 40,
        child: TextField(
          controller: _controller,
          onChanged: (String value) async {
          },
          cursorColor: Colors.black,
          style: _editStyle,
          keyboardType: TextInputType.number,
          cursorWidth: 1,
          obscureText: _obscure,
          textAlign: TextAlign.left,
          maxLines: 1,
          decoration: InputDecoration(
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: color),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: color),
            ),
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: color),
            ),
            hintText: _hint,
            hintStyle: _editStyle,
          ),
        ),
      )
    ],
  );
}
