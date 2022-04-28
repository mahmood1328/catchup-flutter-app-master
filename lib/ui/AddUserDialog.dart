import 'dart:async';
import 'dart:io';

import 'package:catchup/api/auth.dart';
import 'package:catchup/models/user.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../colors.dart';
import 'ErrorDialog.dart';

class AddUserDialog extends StatefulWidget {
  final Function(String username) onItemClick;

  const AddUserDialog({Key key, this.onItemClick}) : super(key: key);

  @override
  _AddUserDialogState createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  List<User> _users;

  Timer _debounce;

  bool _isLoading = false;
  bool _isLoadingButton = false;

  int _selectedIndex = -1;

  void _addUser() async {
    if (_users == null ||
        _users.isEmpty ||
        _selectedIndex < 0 ||
        _selectedIndex >= _users.length) {
      return;
    }

    setState(() {
      _isLoadingButton = true;
    });
    String username = _users[_selectedIndex].username;

    try {
      final added = await Auth.add(username);

      if (added) {
        widget.onItemClick(username);
        Navigator.pop(context, true);
      } else {
        // TODO: User is NOT added!
      }
    } on SocketException {
//      _scaffoldKey.currentState
//          .showSnackBar(ErrorSnackBar("Connection refused!"));
    } on AuthException catch (e) {
//      _scaffoldKey.currentState.showSnackBar(ErrorSnackBar(e.cause));

      showDialog(
        context: context,
        builder: (BuildContext context) => ErrorDialog(
          text: e.cause,
        ),
      );
    }
    setState(() {
      _isLoadingButton=false;
    });
  }

  void _search(username) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final users = await Auth.search(username);

      setState(() {
        _users = users;
        _isLoading = false;
      });
    } on SocketException {
//      _scaffoldKey.currentState
//          .showSnackBar(ErrorSnackBar("Connection refused!"));
    } on AuthException catch (e) {
//      _scaffoldKey.currentState.showSnackBar(ErrorSnackBar(e.cause));
    }
  }

  Widget noUserWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Icon(FontAwesomeIcons.userSlash),
          ),
          SizedBox(height: 10),
          Text(
            'No User!',
            style: TextStyle(
              fontFamily: 'Gothic',
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _getUsersListWidget() {
    if (_isLoading) {
      return Center(
        child: SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(CatchupColors.darkRed),
          ),
        ),
      );
    }

    return _users == null || _users.isEmpty
        ? noUserWidget()
        : ListView.builder(
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  color: index == _selectedIndex
                      ? CatchupColors.gray
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  selected: index == _selectedIndex,
                  leading: Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(_users[index].picture),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  title: Text(
                    _users[index].username,
                    style: TextStyle(
                      fontFamily: 'Gothic',
                    ),
                  ),
                ),
              );
            },
            itemCount: _users.length,
          );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(18),
        decoration: new BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              onChanged: (username) {
                if (_debounce?.isActive ?? false) _debounce.cancel();
                _debounce = Timer(const Duration(milliseconds: 500), () {
                  if (username != null && username.isNotEmpty) {
                    _search(username);
                  }
                });
              },
              keyboardType: TextInputType.text,
              style: TextStyle(
                color: CatchupColors.black,
                fontFamily: 'Gothic',
                fontSize: 20,
              ),
              decoration: InputDecoration(
                hintText: 'Search Username...',
                contentPadding: const EdgeInsets.only(
                  left: 1,
                  bottom: 5,
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
            ),
            SizedBox(height: 20),
            SizedBox(
              height: 150,
              child: Container(
                decoration: BoxDecoration(
                  color: CatchupColors.bgLightGray,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _getUsersListWidget(),
              ),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: _addUser,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                height: 40,
                width: 100,
                decoration: BoxDecoration(
                  color: CatchupColors.red,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Center(
                  child: _isLoadingButton ? CircularProgressIndicator() : Text(
                    'ADD',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Gothic',
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
