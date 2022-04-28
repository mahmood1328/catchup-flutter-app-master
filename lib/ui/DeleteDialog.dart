
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../colors.dart';

class DeleteDialog extends StatefulWidget {
  String title;

  DeleteDialog(this.title);

  @override
  _DeleteDialogState createState() => _DeleteDialogState();
}

class _DeleteDialogState extends State<DeleteDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title , style: TextStyle(color: CatchupColors.red),),
      content: Container(
          height: 20,
          child: Text('you want to delete this item?' , style: TextStyle(color: Colors.white),)),
      backgroundColor: CatchupColors.black,
      actions: [
        GestureDetector(
          onTap: () async{
            Navigator.pop(context);
            //todo implement api
          },
          child: Container(
            width: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: CatchupColors.red,
            ),
            padding: EdgeInsets.symmetric(vertical: 4 , horizontal: 6),
            child: Center(child: Text('Yes')),
          ),
        ),

        GestureDetector(
          onTap: (){
            Navigator.pop(context);
          },
          child: Container(
            width: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: CatchupColors.red,
            ),
            padding: EdgeInsets.symmetric(vertical: 4 , horizontal: 10),
            child: Center(child: Text('No')),
          ),
        ),
      ],
    );
  }
}
