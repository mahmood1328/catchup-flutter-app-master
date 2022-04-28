import 'dart:async';
import 'dart:io';

import 'package:audio_recorder/audio_recorder.dart';
import 'package:catchup/api/auth.dart';
import 'package:catchup/api/chats.dart';
import 'package:catchup/api/urls.dart';
import 'package:catchup/components/voice_componet.dart';
import 'package:catchup/global.dart';
import 'package:catchup/models/chat.dart';
import 'package:catchup/models/group_chat.dart';
import 'package:catchup/models/user.dart';
import 'package:catchup/pages/FeedBackProfilePage.dart';
import 'package:catchup/pages/ProfilePage.dart';
import 'package:catchup/provider/NewChatProvider.dart';
import 'package:catchup/ui/ErrorSnackBar.dart';
import 'package:catchup/ui/RecordAudioDialog.dart';
import 'package:catchup/ui/bubble.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:catchup/colors.dart';
import 'dart:convert';

import 'package:provider/provider.dart';

class ChatsPage extends StatefulWidget {
  final User user;
  final GroupChat group;
  final bool isPrevPageChatsTabsPage;

  const ChatsPage({
    Key key,
    this.user,
    this.group,
    this.isPrevPageChatsTabsPage
  }) : super(key: key);

  @override
  _ChatsPageState createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final _border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(50),
    borderSide: BorderSide(
      color: CatchupColors.gray,
    ),
  );

  final _chatListKey = GlobalKey<AnimatedListState>();

  final _messageController = TextEditingController();

  StreamSubscription<Map> _messageListener;

  bool _isLoading = true;

  bool _isTyping = false;

  void _sendMessage({File file}) async {
    final message = _messageController.text;

    if (message.isNotEmpty || file != null) {
      _messageController.clear();

      final chat = Chat(
        null,
        Global.user.username,
        widget.user != null ? widget.user.username : null,
        file == null ? message : '<FILE>',
        dateTime: DateTime.now(),
        localFile: file,
      );

      _chats.insert(0, chat);
      _chatListKey.currentState.insertItem(0);

      setState(() {
        // Update UI
      });

      try {
        // Send Message
        final sentChat = widget.user != null
            ? await ChatsApi.sendPrivateChat(chat)
            : await ChatsApi.sendGroupChat(widget.group.name, chat);

        setState(() {
          _chats[0] = sentChat;
        });

        // NotificationHandler.showTestNotification(null);
      } on SocketException {
        _scaffoldKey.currentState.hideCurrentSnackBar();

        _scaffoldKey.currentState
            .showSnackBar(ErrorSnackBar("Connection refused!"));
      } on AuthException catch (e) {
        _scaffoldKey.currentState.hideCurrentSnackBar();

        _scaffoldKey.currentState.showSnackBar(ErrorSnackBar(e.cause));
      }
    }
  }

  List<Chat> _chats = [];
  var myModel;
  @override
  void initState() {

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      myModel = Provider.of<ChatModel>(context, listen: false);
      if(!widget.isPrevPageChatsTabsPage)
        myModel.setNewChatNumberZero();

    });
    super.initState();
    /*WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      myModel = Provider.of<ChatModel>(context, listen: false);
      myModel.setNewChatNumberZero();

    });*/
    Global.currentChattingUsername =
        widget.user != null ? widget.user.username : null;

    _loadChats();

    _listenToFirebase();
  }

  Future _listenToFirebase() {
    /*if (Global.chatStreamController.hasListener) {
      return null;
    }*/

    _messageListener = Global.updateChat.listen((Map message) {

      final int id = int.tryParse(message['data']['id']);

      final sender = json.decode(message['data']['sender']);
      final content = json.decode(message['data']['content']);

      final String messageString =
          content['type'] == 'string' ? content['message'] : null;

      final chat = Chat(
        id,
        sender['username'],
        Global.user.username,
        messageString ?? '<FILE>',
        dateTime: DateTime.now(),
        sent: true,
        seen: true,
        file: content['file']
      );

      if(messageString == null ){
      }

      if(sender["username"].toString()==widget.user.username) {
        setState(() {
          _chats.insert(0, chat);
        });

        _chatListKey.currentState.insertItem(_chats.length - 1);
      }
    });

    return null;
  }

  void _loadChats() {
    if (widget.user != null) {
      _loadPrivateChats();
    } else {
      _loadGroupChats();
    }
  }

  void _loadGroupChats() async {
    setState(() {
      _isLoading = true;
    });
    // _scaffoldKey.currentState.hideCurrentSnackBar();

    try {
      final chats = await ChatsApi.groupChats(widget.group.name);

      setState(() {
        _chats = chats;
        _isLoading = false;
      });

      for (int i = 0; i < _chats.length; i++) {
        _chatListKey.currentState.insertItem(i);
      }
    } on SocketException {
      _scaffoldKey.currentState.hideCurrentSnackBar();

      _scaffoldKey.currentState
          .showSnackBar(ErrorSnackBar("Connection refused!"));
    } on AuthException catch (e) {
      _scaffoldKey.currentState.hideCurrentSnackBar();

      _scaffoldKey.currentState.showSnackBar(ErrorSnackBar(e.cause));
    }
  }

  void _loadPrivateChats() async {
    // _scaffoldKey.currentState.hideCurrentSnackBar();

    setState(() {
      _isLoading = true;
    });

   // final localChats = await DBController.privateChats(widget.user.username);

/*    setState(() {
    _chats = localChats;

      if (localChats.length > 0) {
        _isLoading = false;
      }
    });

    for (int i = 0; i < _chats.length; i++) {
      _chatListKey.currentState.insertItem(i);
    }*/

    try {
      final chats = await ChatsApi.privateChats(widget.user.username);

/*      int addedChatsCount = chats.length - localChats.length;
      if (addedChatsCount < 0) {
        addedChatsCount = 0;
      }

      for (final chat in chats) {
        DBController.insertPrivateChat(chat);
      }*/

      setState(() {
        _chats = chats;
        _isLoading = false;

        for (int i = 0; i < _chats.length; i++) {
          _chatListKey.currentState.insertItem(i);
        }
      });

/*      for (int i = localChats.length;
          i < localChats.length + addedChatsCount;
          i++) {
        _chatListKey.currentState.insertItem(i);
      }*/
    } on SocketException {
//      _scaffoldKey.currentState.hideCurrentSnackBar();
//
//      _scaffoldKey.currentState
//          .showSnackBar(ErrorSnackBar("Connection refused!"));
    } on AuthException catch (e) {
      _scaffoldKey.currentState.hideCurrentSnackBar();
      _scaffoldKey.currentState.showSnackBar(ErrorSnackBar(e.cause));
    }
  }

  Widget _getSenderPicture(Chat chat) {
    if (widget.user != null) {
      return Container(
        width: 0,
        height: 0,
      );
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          image: NetworkImage("${Urls.HOST}${chat.profile}"),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  void _sendVoice() async {
    showDialog(
      context: _scaffoldKey.currentContext,
      builder: (BuildContext context) {
        return RecordAudioDialog(
          onRecordDone: (Recording recording) {
            _sendFile(
              path: recording.path,
              extension: recording.extension,
            );
          },
        );
      },
    );
  }

  void _showFileBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text(
                  'Camera',
                  style: TextStyle(
                    fontFamily: 'Gothic',
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);

                  _sendImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.image),
                title: Text(
                  'Gallery',
                  style: TextStyle(
                    fontFamily: 'Gothic',
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);

                  _sendImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.keyboard_voice),
                title: Text(
                  'Voice',
                  style: TextStyle(
                    fontFamily: 'Gothic',
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);

                  _sendVoice();
                },
              ),
              ListTile(
                leading: Icon(Icons.insert_drive_file),
                title: Text(
                  'File',
                  style: TextStyle(
                    fontFamily: 'Gothic',
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);

                  _sendFile();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _sendImage(ImageSource source) async {
    final PickedFile image = await ImagePicker().getImage(source: source);

    if (image == null) {
      return;
    }

    _sendMessage(file: File(image.path));
  }

  void _sendFile({String path, String extension}) async {
    if (path != null) {
      final File f = File(path);

      if (f != null && await f.exists()) {
        _sendMessage(file: f);
      }

      return;
    }

    File file = await FilePicker.getFile();

    if (file == null) {
      return;
    }

    _sendMessage(file: file);
  }

  String _getTimeString(Chat chat) {
    String result = '${chat.dateTime.year}/';

    if (chat.dateTime.month < 10) {
      result += '0';
    }

    result += '${chat.dateTime.month}/';

    if (chat.dateTime.day < 10) {
      result += '0';
    }

    result += '${chat.dateTime.day} ';

    if (chat.dateTime.hour < 10) {
      result += '0';
    }

    result += '${chat.dateTime.hour}:';

    if (chat.dateTime.minute < 10) {
      result += '0';
    }

    result += '${chat.dateTime.minute}';

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: CatchupColors.darkRed,
        title: Text(
          widget.user != null ? widget.user.fullName : widget.group.name,
          style: TextStyle(fontFamily: 'Gothic'),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(widget.user != null ? Icons.person : Icons.group),
            onPressed: () {
              if (widget.user != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FeedBackProfilePage(username :widget.user.username),
                  ),
                );
              } else {}
            },
          ),
        ],
      ),
      body: Container(
        color: CatchupColors.black,
        child: Stack(
          children: <Widget>[
            _isLoading
                ? Center(
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(
                        strokeWidth: 1,
                        valueColor: new AlwaysStoppedAnimation<Color>(
                            CatchupColors.red),
                      ),
                    ),
                  )
                : Container(
                    width: 0,
                    height: 0,
                  ),
            AnimatedList(
              key: _chatListKey,
              reverse: true,
              scrollDirection: Axis.vertical,
              padding: EdgeInsets.only(
                top: 10,
                left: 10,
                right: 10,
                bottom: 110,
              ),
              shrinkWrap: false,
              initialItemCount: _chats.length,
              itemBuilder: (context, index, animation) {
                final chat = _chats[index];

                bool isVoice = false;
                if (chat.file != null) {
                  final String filename = chat.file.split('/').last;

                  if (filename == null || filename.isEmpty) {
                    return Text('CROPTED FILE');
                  }

                  final String extension = filename.split('.').last;
                   isVoice =
                      'm4a' == extension.toLowerCase();
                }

                return FadeTransition(
                  opacity: animation,
                  child: Container(
                    child: Row(
                      mainAxisAlignment: chat.isMe
                          ? MainAxisAlignment.start
                          : MainAxisAlignment.end,
                      children: <Widget>[
                        _getSenderPicture(chat),
                        !isVoice?
                        Padding(
                          padding: EdgeInsets.only(
                            top: widget.user == null ? 15 : 0,
                          ),
                          child: Bubble(
                            message: chat.message,
                            time: _getTimeString(chat),
                            delivered: chat.sent,
                            seen: chat.seen,
                            isMe: chat.isMe,
                            file: chat.file,
                          ),
                        )
                          :VoiceComponet(file: chat.file,
                          time: _getTimeString(chat),
                            delivered: chat.sent,
                            seen: chat.seen,
                            isMe: chat.isMe,)
                      ],
                    ),
                  ),
                );
              },
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: <Widget>[
                      TextFormField(
                        onFieldSubmitted: (term) {
                          _sendMessage();
                        },
                        onChanged: (String term) {
                          setState(() {
                            _isTyping = term.isNotEmpty;
                          });
                        },
                        controller: _messageController,
                        textInputAction: TextInputAction.send,
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Gothic',
                          fontSize: 15,
                        ),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(
                            left: 15,
                            right: 100,
                          ),
                          hintText: 'Type your message...',
                          filled: true,
                          fillColor: CatchupColors.gray,
                          hintStyle: TextStyle(
                            color: Colors.white38,
                          ),
                          border: _border,
                          enabledBorder: _border,
                          focusedBorder: _border,
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            IconButton(
                              onPressed: _showFileBottomSheet,
                              icon: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: CatchupColors.bgLightGray,
                                ),
                                child: Icon(
                                  Icons.attach_file,
                                  color: CatchupColors.gray,
                                  size: 23,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                if (_isTyping) {
                                  _sendMessage();
                                } else {
                                  _sendVoice();
                                }
                              },
                              icon: _isTyping
                                  ? Container(
                                      padding: const EdgeInsets.all(7),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: CatchupColors.bgLightGray,
                                      ),
                                      child: Icon(
                                        Icons.send,
                                        color: CatchupColors.gray,
                                        size: 17,
                                      ),
                                    )
                                  : Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: CatchupColors.bgLightGray,
                                      ),
                                      child: Icon(
                                        Icons.keyboard_voice,
                                        color: CatchupColors.gray,
                                        size: 23,
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    if(!widget.isPrevPageChatsTabsPage)
      myModel.setincreaseNewChatNumber(true);

  _messageController.dispose();

    if (_messageListener != null) {
      _messageListener.cancel();
    }

    //Global.chatStreamController.close();

    //Global.chatStreamController = StreamController<Map>();

    //myModel.listenToStream();

    super.dispose();
  }
}
