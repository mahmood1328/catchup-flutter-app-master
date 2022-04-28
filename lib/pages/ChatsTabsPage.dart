import 'dart:io';

import 'package:catchup/api/auth.dart';
import 'package:catchup/api/chats.dart';
import 'package:catchup/components/menu_float.dart';
import 'package:catchup/db_controller.dart';
import 'package:catchup/models/group_chat.dart';
import 'package:catchup/models/user.dart';
import 'package:catchup/pages/ContactsPage.dart';
import 'package:catchup/provider/NewChatProvider.dart';
import 'package:catchup/ui/ErrorSnackBar.dart';
import 'package:flutter/material.dart';

import 'package:catchup/colors.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../global.dart';
import 'ChatsPage.dart';

class ContactsTabsPage extends StatefulWidget {
  ContactsTabsPage({Key key}) : super(key: key);


  @override
  _ContactsTabsPageState createState() => _ContactsTabsPageState();
}

class _ContactsTabsPageState extends State<ContactsTabsPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List<User> _privateChats;
  List _groupChats;

  bool _isLoadingChats = true;
  var myModel;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
       myModel = Provider.of<ChatModel>(context, listen: false);
      myModel.setNewChatNumberZero();

    });

    //Global.clearChatNumberController.add("message");

    _loadChats();
  }

  void _loadChats() async {
    // _scaffoldKey.currentState.hideCurrentSnackBar();
    setState(() {
      _isLoadingChats = true;
    });

    final contacts = await DBController.contacts();

    setState(() {
      _privateChats = contacts;

      if (contacts.length > 0) {
        _isLoadingChats = false;
      }
    });

    try {
      final List chatResult = await ChatsApi.chats();

      for (final user in chatResult[0]) {
        DBController.insertContact(user);
      }

      if(mounted)
      setState(() {
        _privateChats = chatResult[0];
        _groupChats = chatResult[1];
        _isLoadingChats = false;
      });
    } on SocketException {
//      _scaffoldKey.currentState.hideCurrentSnackBar();

//      _scaffoldKey.currentState
//          .showSnackBar(ErrorSnackBar("Connection refused!"));

      setState(() {
        _isLoadingChats = false;
      });
    } on AuthException catch (e) {
      _scaffoldKey.currentState.hideCurrentSnackBar();

      _scaffoldKey.currentState.showSnackBar(ErrorSnackBar(e.cause));

      setState(() {
        _isLoadingChats = false;
      });
    }
  }

  Widget _empty(String text) {
    if (_isLoadingChats) {
      return Center(
        child: SizedBox(
          width: 50,
          height: 50,
          child: CircularProgressIndicator(
            strokeWidth: 1,
            valueColor: new AlwaysStoppedAnimation<Color>(CatchupColors.red),
          ),
        ),
      );
    }

    return Center(
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontFamily: 'Gothic',
          fontSize: 18,
        ),
      ),
    );
  }

  void _newChat() async {
    final User contact = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContactsPage(),
      ),
    );

    if (contact == null) {
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatsPage(user: contact,isPrevPageChatsTabsPage:true),
      ),
    );

    _loadChats();
  }

  void _newGroup() async {
    final List result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContactsPage(isGroup: true),
      ),
    );

    if (result == null) {
      return;
    }

    final String groupName = result[0];
    final List<User> groupMembers = result[1];

    if (groupName == null || groupMembers == null || groupMembers.isEmpty) {
      return;
    }

    // _scaffoldKey.currentState.hideCurrentSnackBar();

    try {
      final GroupChat groupChat =
      await ChatsApi.createGroupChat(groupName, groupMembers);

      setState(() {
        _groupChats.add(groupChat.name);
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatsPage(group: groupChat,isPrevPageChatsTabsPage:true),
        ),
      );
    } on SocketException {
      _scaffoldKey.currentState.hideCurrentSnackBar();

      _scaffoldKey.currentState
          .showSnackBar(ErrorSnackBar("Connection refused!"));
    } on AuthException catch (e) {
      _scaffoldKey.currentState.hideCurrentSnackBar();

      _scaffoldKey.currentState.showSnackBar(ErrorSnackBar(e.cause));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: CatchupColors.darkRed,
          title: Text(
            'Chat',
            style: TextStyle(fontFamily: 'Gothic'),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.group_add),
              onPressed: _newGroup,
            ),
          ],
          bottom: TabBar(
            indicatorColor: CatchupColors.red,
            tabs: [
              Tab(icon: Icon(Icons.person)),
              Tab(icon: Icon(Icons.people)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Container(
              color: CatchupColors.black,
              child: (_privateChats == null || _privateChats.isEmpty)
                  ? _empty('No Chats!')
                  : ListView.builder(
                scrollDirection: Axis.vertical,
                padding: EdgeInsets.only(top: 10),
                shrinkWrap: true,
                itemCount: _privateChats.length,
                itemBuilder: (BuildContext context, int index) {
                  final User user = _privateChats[index];

                  return Card(
                    elevation: 8.0,
                    margin: new EdgeInsets.symmetric(
                      horizontal: 15.0,
                      vertical: 7.0,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: CatchupColors.gray.withOpacity(0.9),
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
                                image: DecorationImage(
                                    image: NetworkImage(user.picture),
                                    fit: BoxFit.cover
                                ),
                                shape: BoxShape.circle
                            ),
                          ),
                        ),
                        title: Text(
                          user.fullName,
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
                        trailing: Text(
                          '',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Gothic',
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatsPage(user: user,isPrevPageChatsTabsPage:true),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              color: CatchupColors.black,
              child: (_groupChats == null || _groupChats.isEmpty)
                  ? _empty('No Groups!')
                  : ListView.builder(
                scrollDirection: Axis.vertical,
                padding: EdgeInsets.only(top: 10),
                shrinkWrap: true,
                itemCount: _groupChats.length,
                itemBuilder: (BuildContext context, int index) {
                  final groupName = _groupChats[index];

                  return Card(
                    elevation: 8.0,
                    margin: new EdgeInsets.symmetric(
                      horizontal: 15.0,
                      vertical: 7.0,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: CatchupColors.gray.withOpacity(0.9),
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
                          child: Icon(Icons.group),
                        ),
                        title: Text(
                          groupName,
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Gotham',
                          ),
                        ),
                        
                        trailing: Text(
                          '',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Gothic',
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatsPage(
                                group: GroupChat(null, groupName),
                                  isPrevPageChatsTabsPage:true
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _newChat,
          backgroundColor: CatchupColors.red,
          child: Icon(Icons.chat),
        ),
      ),
    );
  }

  @override
  void dispose() {
    myModel.setincreaseNewChatNumber(true);
    super.dispose();
  }
}
