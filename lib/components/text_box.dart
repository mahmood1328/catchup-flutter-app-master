import 'package:catchup/colors.dart';

import 'package:flutter/material.dart';

// ignore: must_be_immutable
class GrayTextBox extends StatelessWidget {
  final String hint;
  final Color textColor;
  final TextAlign textAlign;
  final bool obscureText;
  final bool readOnly;
  final String initialValue;
  final Widget prefixIcon;
   TextEditingController controller = TextEditingController();

   GrayTextBox({
    Key key,
    this.hint = '',
    this.textColor = Colors.white,
    this.textAlign = TextAlign.start,
    this.obscureText = false,
    this.readOnly = false,
    this.initialValue,
    this.prefixIcon,
    this.controller
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      maxLines: 1,
      minLines: 1,
      readOnly: readOnly,
      textAlign: textAlign,
      obscureText: obscureText,
      textAlignVertical: TextAlignVertical.center,
      style: TextStyle(
        color: textColor,
        fontFamily: 'Gothic',
      ),
      decoration: InputDecoration(
        hintText: hint,
        isDense: true,
        prefixIcon: prefixIcon,
        contentPadding: EdgeInsets.only(
          left: prefixIcon != null ? 25 : 1,
          bottom: prefixIcon != null ? 0 : 7,
          right: 1,
        ),
        hintStyle: TextStyle(
          color: CatchupColors.lightGray,
        ),
        border: UnderlineInputBorder(
          borderSide: BorderSide(
            color: CatchupColors.lightGray,
          ),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: CatchupColors.gray,
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: CatchupColors.lightGray,
            width: 2,
          ),
        ),
      ),
    );
  }
}
