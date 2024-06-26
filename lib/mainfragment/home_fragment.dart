import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:instasave/mainfragment/webview_fragment.dart';
import 'package:instasave/utils/constants.dart';
import 'package:instasave/widgets/primary_button.dart';

class HomeFragment extends StatefulWidget {
  const HomeFragment({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HomeFragment> {
  final _urlController = TextEditingController();
  bool _validUrl = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            child: TextField(
              maxLines: 1,
              decoration: InputDecoration(labelText: "Enter Url"),
              controller: _urlController,
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              const SizedBox(width: 10),
              Expanded(
                child: PrimaryButton(
                  text: "How To?",
                  onPressed: onPressed,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                  child: PrimaryButton(
                text: "Download",
                onPressed: onDownloadPressed,
              )),
              const SizedBox(width: 10),
              Expanded(
                  child: PrimaryButton(
                text: "Paste",
                onPressed: onPressed,
              )),
              const SizedBox(width: 10)
            ],
          )
        ],
      ),
    );
  }

  void onPressed() {}

  void onDownloadPressed() {
    _validUrl = checkUrl(_urlController.text);
    if (_validUrl) {
      // checkStoragePermission(_urlController.text);
      // validateUrl(_urlController.text);
      validateUrl("https://www.instagram.com/p/C4ddoser7C1/?hl=en");
    }
  }

  bool checkUrl(String text) {
    text = "https://www.instagram.com/p/C4ddoser7C1/?hl=en";
    if (text.isEmpty) {
      Fluttertoast.showToast(msg: "Enter Url");
      return false;
    } else if (RegExp(FEEDS_PATTERN).hasMatch(text)) {
      return true;
    } else if (RegExp(REELS_PATTERN).hasMatch(text)) {
      return true;
    } else if (RegExp(IG_TV_PATTERN).hasMatch(text)) {
      return true;
    } else {
      Fluttertoast.showToast(msg: "Invalid URl");
    }
    return false;
  }

  Future<void> checkStoragePermission(String url) async {}

  void validateUrl(String postUrl) {
    String replacedUrl = "";
    if (postUrl.contains("?utm_source=ig_web_copy_link")) {
      String partToRemove = "?utm_source=ig_web_copy_link";
      replacedUrl = postUrl.replaceAll(partToRemove, "");
    } else if (postUrl.contains("?utm_source=ig_web_button_share_sheet")) {
      String partToRemove = "?utm_source=ig_web_button_share_sheet";
      replacedUrl = postUrl.replaceAll(partToRemove, "");
    } else if (postUrl.contains("?utm_medium=share_sheet")) {
      String partToRemove = "?utm_medium=share_sheet";
      replacedUrl = postUrl.replaceAll(partToRemove, "");
    } else if (postUrl.contains("?utm_medium=copy_link")) {
      String partToRemove = "?utm_medium=copy_link";
      replacedUrl = postUrl.replaceAll(partToRemove, "");
    } else {
      replacedUrl = postUrl;
    }
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => WebViewFragment(url: replacedUrl)));
  }
}
