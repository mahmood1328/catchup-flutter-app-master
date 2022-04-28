

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../global.dart';

class ChatModel with ChangeNotifier {
  bool increaseNewChatNumber = true;
  int newChatNumber=0;
  void updateNewChatNumer(){
    print("updateNewChatNumer");
    if(increaseNewChatNumber)
      {SharedPreferences.getInstance().then((pref) {
        if(pref.getInt("newChatNumber")==null)
          pref.setInt("newChatNumber", 1);
        else
          pref.setInt("newChatNumber", pref.getInt("newChatNumber")+1);
          newChatNumber=pref.getInt("newChatNumber");
        notifyListeners();

      });
      print("increase ");
      }
  }
  void setNewChatNumerFromPrefs(){
    print("setNewChatNumerFromPrefs");
    SharedPreferences.getInstance().then((pref) {
      if(pref.getInt("newChatNumber")!=null)
        {
          newChatNumber=pref.getInt("newChatNumber");
          print(pref.getInt("newChatNumber".toString()+"*****"));
        }
      else print(newChatNumber.toString()+"^^");
      notifyListeners();

    });
  }
  void setincreaseNewChatNumber(bool a) {
    increaseNewChatNumber=a;
    print("setincreaseNewChatNumber"+a.toString());
    //notifyListeners();
  }
  void setNewChatNumberZero()
  {
    print("setNewChatNumberZero ");
    SharedPreferences.getInstance().then((pref) {
        pref.setInt("newChatNumber", 0);
    });
    increaseNewChatNumber=false;

    newChatNumber=0;
    notifyListeners();
  }
  void listenToStream(){
    Global.updateChat.listen((Map message) {
      if(message.containsKey('notification')&& message["notification"]["body"]!=null)
      {  if(message["data"]["task"]==null)
        updateNewChatNumer();
      }

    });
  }
}

