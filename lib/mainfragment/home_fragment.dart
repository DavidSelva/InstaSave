import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:instasave/utils/PrefUtils.dart';
import 'package:instasave/utils/constants.dart';
import 'package:instasave/widgets/primary_button.dart';
import 'package:permission_handler/permission_handler.dart';

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
      checkStoragePermission(_urlController.text);
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

  Future<void> checkStoragePermission(String url) async {
    if (Platform.isAndroid) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      if (androidInfo.version.sdkInt <= 32) {
        if (await Permission.storage.isGranted) {
          if (PrefUtils.getString(PrefUtils.USER_ID ?? "", "").isNotEmpty) {
          } else {}
        } else {
          final result = await Permission.photos.request();
          if (result.isGranted) {
            final result = await Permission.videos.request();
            if (result.isGranted) {
            } else if (result.isDenied) {
              // Permission is denied
            } else if (result.isPermanentlyDenied) {
              // Permission is permanently denied
            }
          } else if (result.isDenied) {
            // Permission is denied
          } else if (result.isPermanentlyDenied) {
            // Permission is permanently denied
          }
        }
      } else {
        if (await Permission.photos.isGranted &&
            await Permission.videos.isGranted) {
          if (PrefUtils.getString(PrefUtils.USER_ID ?? "", "").isNotEmpty) {
          } else {}
        } else {
          final result = await Permission.storage.request();
          if (result.isGranted) {
            // Permission is granted
          } else if (result.isDenied) {
            // Permission is denied
          } else if (result.isPermanentlyDenied) {
            // Permission is permanently denied
          }
        }
      }
    }
  }
}
