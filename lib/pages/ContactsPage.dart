import 'dart:io';

import 'package:catchup/api/auth.dart';
import 'package:catchup/components/menu_float.dart';
import 'package:catchup/models/user.dart';
import 'package:catchup/ui/AddUserDialog.dart';
import 'package:catchup/ui/ErrorSnackBar.dart';
import 'package:flutter/material.dart';

import 'package:catchup/colors.dart';

class ContactsPage extends StatefulWidget {
  final bool isGroup;

  const ContactsPage({
    Key key,
    this.isGroup = false,
  }) : super(key: key);

  @override
  _ContactsPageState createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final _groupController = TextEditingController();

  final _border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(50),
    borderSide: BorderSide(
      color: CatchupColors.gray,
    ),
  );

  List<Widget> _actions = [];

  List<User> _contacts;

  void _addNewContact() {
    showDialog(
      context: _scaffoldKey.currentContext,
      builder: (BuildContext context) => AddUserDialog(
        onItemClick: (username) async {
          final profile = await Auth.profile(
            username: username,
          );

          final user = User.fromJson(profile);

          if (!_contacts.contains(user)) {
            setState(() {
              _contacts.add(user);
            });
          }
        },
      ),
    );
  }

  Widget _groupNameWidget() {
    if (!widget.isGroup) {
      return Container(
        width: 0,
        height: 0,
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.only(
          top: 30,
          left: 20,
          right: 20,
        ),
        child: Container(
          height: 50,
          child: TextFormField(
            controller: _groupController,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Gothic',
              fontSize: 20,
            ),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 5),
              hintText: 'Group Name',
              filled: true,
              fillColor: CatchupColors.bgLightGray,
              prefixIcon: Icon(
                Icons.group,
                color: CatchupColors.gray,
              ),
              hintStyle: TextStyle(
                color: CatchupColors.lightGray,
              ),
              border: _border,
              enabledBorder: _border,
              focusedBorder: _border,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _actions.add(IconButton(
      icon: Icon(Icons.person_add),
      onPressed: _addNewContact,
    ));

    if (widget.isGroup) {
      _actions.add(IconButton(
        icon: Icon(Icons.check),
        onPressed: _done,
      ));
    }

    _loadContacts();
  }

  void _loadContacts() async {
    //_scaffoldKey.currentState.hideCurrentSnackBar();

    try {
      final List contacts = await Auth.users();

      setState(() {
        _contacts = contacts;
      });
    } on SocketException {
      _scaffoldKey.currentState.hideCurrentSnackBar();

      _scaffoldKey.currentState
          .showSnackBar(ErrorSnackBar("Connection refused!"));
    } on AuthException catch (e) {
      _scaffoldKey.currentState.hideCurrentSnackBar();

      _scaffoldKey.currentState.showSnackBar(ErrorSnackBar(e.cause));
    }
  }

  void _done() async {
    // _scaffoldKey.currentState.hideCurrentSnackBar();

    final String groupName = _groupController.text;

    if (groupName.isEmpty) {
      _scaffoldKey.currentState
          .showSnackBar(ErrorSnackBar("Please enter a group name!"));
      return;
    }

    final List<User> groupMembers =
        _contacts.where((user) => user.isSelected).toList();

    if (groupMembers.isEmpty) {
      _scaffoldKey.currentState
          .showSnackBar(ErrorSnackBar("Please select atleast one contact!"));
      return;
    }

    Navigator.of(_scaffoldKey.currentContext).pop([groupName, groupMembers]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: CatchupColors.darkRed,
        title: Text(
          widget.isGroup ? 'Create Group' : 'Contacts',
          style: TextStyle(fontFamily: 'Gothic'),
        ),
        actions: _actions,
      ),
      body: Stack(
        children: [
          Container(
            color: CatchupColors.black,
            child: (_contacts == null || _contacts.isEmpty)
                ? Center(
              child: Text(
                'No Contacts!',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Gothic',
                  fontSize: 18,
                ),
              ),
            )
                : Column(
              children: <Widget>[
                _groupNameWidget(),
                ListView.builder(
                  scrollDirection: Axis.vertical,
                  padding: EdgeInsets.only(top: 10),
                  itemCount: _contacts.length,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    final User user = _contacts[index];

                    return Card(
                      elevation: 8.0,
                      margin: new EdgeInsets.symmetric(
                        horizontal: 15.0,
                        vertical: 7.0,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: CatchupColors.gray
                              .withOpacity(user.isSelected ? 0.5 : 0.9),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 10.0,
                          ),
                          leading: Container(
                            padding: EdgeInsets.only(right: 12.0),
                            decoration: new BoxDecoration(
                              border: new Border(
                                right: new BorderSide(
                                  width: 1.0,
                                  color: Colors.white24,
                                ),
                              ),
                            ),
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: NetworkImage(user.picture),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            '${user.firstName} ${user.lastName}',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Gotham',
                            ),
                          ),
                          subtitle: Text(
                            '@${user.username}',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Gothic',
                            ),
                          ),
                          trailing: Opacity(
                            opacity: user.isSelected ? 1 : 0,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Icon(
                                Icons.check_circle,
                                color: CatchupColors.darkRed,
                              ),
                            ),
                          ),
                          onTap: () {
                            // Contact Selected
                            if (widget.isGroup) {
                              user.isSelected = !user.isSelected;
                              setState(() => {});
                              return;
                            }

                            Navigator.pop(context, user);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          MenuFloat(position: Offset(40, 40),),
        ],
      ),
    );
  }
}
