import 'dart:io';
import 'dart:math' as math;

import 'package:catchup/api/auth.dart';
import 'package:catchup/api/urls.dart';
import 'package:catchup/colors.dart';
import 'package:catchup/components/menu_float.dart';
import 'package:catchup/global.dart';
import 'package:catchup/models/user.dart';
import 'package:catchup/pages/ChatsTabsPage.dart';
import 'package:catchup/pages/ProfilePage.dart';
import 'package:catchup/ui/AddUserDialog.dart';
import 'package:catchup/ui/ArcChooser.dart';
import 'package:catchup/ui/ErrorDialog.dart';
import 'package:catchup/ui/ErrorSnackBar.dart';
import 'package:catchup/ui/MainCircularMenu.dart';
import 'package:catchup/ui/SearchBox.dart';
import 'package:catchup/ui/picker.dart';
import 'package:catchup/ui/user_card.dart';
import 'package:flutter/material.dart';

class UsersListPage extends StatefulWidget {
  @override
  _UsersListPageState createState() => _UsersListPageState();
}

class _UsersListPageState extends State<UsersListPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final _searchController = TextEditingController();

  final _listKey = GlobalKey();

  GlobalKey _keyCupertino = GlobalKey();

  List<User> _users;
  List<User> _filteredUsers;

  static final ctrl = FixedExtentScrollController();

  int _selectedIndex = 0;

  void _loadContacts() async {
    try {
      final users = await Auth.users();

      setState(() {
        _users = users;
        _filteredUsers = users;
      });
    } on SocketException {
      _scaffoldKey.currentState
          .showSnackBar(ErrorSnackBar("Connection refused!"));
    } on AuthException catch (e) {
      _scaffoldKey.currentState.showSnackBar(ErrorSnackBar(e.cause));
    }
  }

  void _addUser() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AddUserDialog(
        onItemClick: (username) async {
          final profile = await Auth.profile(
            username: username,
          );

          setState(() {
            if (_users.length == 0) {
              _keyCupertino = GlobalKey();
            }

            _users.add(User.fromJson(profile));

            if (_users.length > 1) {
              ctrl.animateToItem(
                _users.length - 1,
                duration: Duration(milliseconds: 250),
                curve: Curves.easeInOut,
              );
            }
          });
        },
      ),
    );
  }

  void _openChat() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContactsTabsPage(),
      ),
    );
  }

  void _openUserProfile(User user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(
          user: user,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _loadContacts();
  }

  @override
  Widget build(BuildContext context) {
    Global.screenSize = MediaQuery.of(context).copyWith().size;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: CatchupColors.black,
      body: Stack(
        children: <Widget>[
          SafeArea(
            child: Column(
              children: <Widget>[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 50,
                      right: 50,
                      top: 20,
                    ),
                    child: Image.asset(
                      'assets/logo.png',
                      width: 200,
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 30,
                      left: 20,
                      right: 20,
                    ),
                    child: SearchBox(
                      controller: _searchController,
                      onSearch: (text) {
                        setState(() {
                          text = text.trim().toLowerCase();

                          if (text.isEmpty) {
                            _filteredUsers = _users;
                            return;
                          }

                          _filteredUsers = _users.where((u) {
                            if (u.username.toLowerCase().startsWith(text))
                              return true;

                            if (u.firstName.toLowerCase().startsWith(text))
                              return true;

                            if (u.lastName.toLowerCase().startsWith(text))
                              return true;

                            return false;
                          }).toList();
                        });
                      },
                    ),
                  ),
                ),
                Expanded(
                  key: _listKey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: (_filteredUsers == null || _filteredUsers.isEmpty)
                        ? Center(
                            child: Text(
                              'No User Found!',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Gothic',
                                fontSize: 20,
                              ),
                            ),
                          )
                        : GestureDetector(
                            onTapUp: (TapUpDetails details) {
                              final x = details.globalPosition.dx;

                              final RenderBox box =
                                  _listKey.currentContext.findRenderObject();

                              final pos = box.localToGlobal(Offset.zero);
                              final size = box.size;

                              final y = details.globalPosition.dy - pos.dy;

                              final w =
                                  MediaQuery.of(context).copyWith().size.width -
                                      30;
                              final h = 104.0;

                              final yStart = (size.height - h) / 2;
                              final yEnd = (size.height + h) / 2;

                              if (x >= 30 &&
                                  x <= w &&
                                  y >= yStart &&
                                  y <= yEnd) {
                                _openUserProfile(_users[_selectedIndex]);
                              }
                            },
                            child: UserPicker.builder(
                              key: _keyCupertino,
                              scrollController: ctrl,
                              backgroundColor: Colors.transparent,
                              childCount: _filteredUsers.length,
                              itemBuilder: (context, index) {
                                final user = _filteredUsers[index];

                                return UserCard(
                                  title: '${user.firstName} ${user.lastName}',
                                  imageUrl: user.picture,
                                  value: -1.0,
                                );
                              },
                              itemExtent: 130,
                              //height of each item
//                              looping: false,
                              onSelectedItemChanged: (int index) {
                                _selectedIndex = index;
                              },
                            ),
                          ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      GestureDetector(
                        onTap: _openChat,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20, bottom: 20),
                          child: Text(
                            'Chat',
                            style: TextStyle(
                              color: CatchupColors.red,
                              fontFamily: 'Gothic',
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _addUser,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 20, bottom: 20),
                          child: Text(
                            '+ Add User',
                            style: TextStyle(
                              color: CatchupColors.red,
                              fontFamily: 'Gothic',
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          MenuFloat(position: Offset(40, 40),),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }
}
