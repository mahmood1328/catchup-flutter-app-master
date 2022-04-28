import 'package:flutter/cupertino.dart';

class MyModel with ChangeNotifier {
  bool downloaded = false;

  void setDownloaded() {
    downloaded = true;
    print(downloaded);
    notifyListeners();
  }
}