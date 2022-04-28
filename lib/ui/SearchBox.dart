import 'package:flutter/material.dart';

import '../colors.dart';

class SearchBox extends StatefulWidget {
  final TextEditingController controller;
  final Function(String text) onSearch;

  const SearchBox({
    Key key,
    this.controller,
    this.onSearch,
  }) : super(key: key);

  @override
  _SearchBoxState createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  final _border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(50),
    borderSide: BorderSide(
      color: CatchupColors.gray,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: 350),
      height: 40,
      child: TextFormField(
        controller: widget.controller,
        textInputAction: TextInputAction.search,
        onFieldSubmitted: (text) {
          widget.onSearch(text);
        },
        style: TextStyle(
          color: Colors.white,
          fontFamily: 'Gothic',
          fontSize: 17,
        ),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 5),
          hintText: 'Search',
          filled: true,
          fillColor: CatchupColors.bgLightGray,
          prefixIcon: Icon(
            Icons.search,
            color: CatchupColors.gray,
            size: 20,
          ),
          hintStyle: TextStyle(
            color: CatchupColors.lightGray,
          ),
          border: _border,
          enabledBorder: _border,
          focusedBorder: _border,
        ),
      ),
    );
  }
}
