import 'package:flutter/material.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:insta_login/insta_login.dart';
import 'package:instasave/mainfragment/webview_fragment.dart';
import 'package:instasave/utils/constants.dart';
import 'package:instasave/utils/instagram_api.dart';
import 'package:instasave/utils/pref_utils.dart';
import 'package:instasave/widgets/primary_button.dart';

class HomeFragment extends StatefulWidget {
  const HomeFragment({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HomeFragment> {
  final _urlController = TextEditingController();
  bool _validUrl = false;
  final plugin = FacebookLogin(debug: true);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

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
    } else if (RegExp(APIConstants.FEEDS_PATTERN).hasMatch(text)) {
      return true;
    } else if (RegExp(APIConstants.REELS_PATTERN).hasMatch(text)) {
      return true;
    } else if (RegExp(APIConstants.IG_TV_PATTERN).hasMatch(text)) {
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
    String feedGraphUrl = InstagramAPI.getFeedGraphUrl(replacedUrl);
    if (PrefUtils.getString(PrefUtils.PREF_KEY_ACCESS_TOKEN, "").isEmpty) {
      // instaLogin(feedGraphUrl);
      showDialog(
          context: context,
          builder: (context) => WebViewFragment(
              postUrl: postUrl,
              accessTokenCallback: (code) async {
                Map<String, dynamic> shortToken = await Instaservices()
                    .getTokenAndUserID(
                        appid: APIConstants.INSTA_APP_ID,
                        redirectUrl: APIConstants.REDIRECT_URL,
                        code: code,
                        appSecret: APIConstants.INSTA_APP_SECRET);
                Navigator.pop(context);
                /** Store Short Live Token*/
                PrefUtils.saveString(
                    PrefUtils.PREF_KEY_ACCESS_TOKEN, shortToken["access_token"]);
                PrefUtils.saveString(
                    PrefUtils.PREF_KEY_USER_ID, shortToken["user_id"]);
                /*PrefUtils.saveDouble(
                    PrefUtils.PREF_KEY_ACCESS_TOKEN_EXPIRY, shortToken["expires_in"]);*/
                InstagramAPI.getInstaUserName(
                    accesstoken: shortToken["access_token"], accessTokenCallback: (userMap) async {});

                /** Get Long Live Token*/
                // getLongLiveToken(shortToken);
              }));
    } else {
      InstagramAPI.getInstaUserName(
          accesstoken: PrefUtils.getString(PrefUtils.PREF_KEY_ACCESS_TOKEN, ""), accessTokenCallback: (userMap) async {});
    }
  }

  void instaLogin(String feedGraphUrl) async {
    String loginResponse = await InstagramAPI.getAuthorization();
    if (loginResponse.isNotEmpty) {
      // Instaservices().getTokenAndUserID(appid: APIConstants.INSTA_APP_ID, redirectUrl: APIConstants.REDIRECT_URL, code: code, appSecret: appSecret)
    }
  }

  Future<void> _updateLoginInfo(String feedGraphUrl) async {
    final token = await plugin.accessToken;
    FacebookUserProfile? profile;
    String? email;

    if (token != null) {
      PrefUtils.saveString(
          PrefUtils.PREF_KEY_ACCESS_TOKEN, token.token.toString());
      profile = await plugin.getUserProfile();
      if (token.permissions.contains(FacebookPermission.email.name)) {
        email = await plugin.getUserEmail();
      }
      getFeedInfo(token.token.toString(), feedGraphUrl);
    }
    // LoggerUtils.logger.d("_updateLoginInfo: ${token?.authenticationToken.toString()}");
    // LoggerUtils.logger.d("_updateLoginInfo: ${token?.token.toString()}");
    // LoggerUtils.logger.d("_updateLoginInfo: $email");
  }

  void getLongLiveToken(Map<String, dynamic> shortToken) {
    InstagramAPI.getLongLiveToken(shortToken,
        accessTokenCallback: (longToken) async {
      InstagramAPI.getInstaUserName(
          accesstoken: longToken, accessTokenCallback: (userMap) async {});
    });
  }
}

void getFeedInfo(String token, String feedUrl) {
  /*InstagramAPI.getDownloadInfo(token?.token, feedGraphUrl,
        userInfoCallback: (response, position, type) {});*/
  InstagramAPI.getUserInfoUsingToken(token.toString(),
      userInfoCallback: (response, position, type) {});
}
