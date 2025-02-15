import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:instasave/utils/constants.dart';
import 'package:instasave/utils/instagram_api.dart';
import 'package:instasave/utils/logger_utils.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../utils/pref_utils.dart';

class WebViewFragment extends StatefulWidget {
  final String postUrl;
  final Function accessTokenCallback;

  const WebViewFragment(
      {super.key, required this.postUrl, required this.accessTokenCallback});

  @override
  State<WebViewFragment> createState() => _WebViewFragmentState();
}

class _WebViewFragmentState extends State<WebViewFragment> {
  late final WebViewController controller;

  // late final CookieManager _cookieManager = CookieManager.instance();

  @override
  void initState() {
    if (PrefUtils.getString(PrefUtils.PREF_KEY_ACCESS_TOKEN, "").isEmpty) {
      controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(NavigationDelegate(
            onProgress: (int progress) {},
            onPageFinished: (String pageUrl) async {
              LoggerUtils.logger.d("initState: $pageUrl");

              /** Cookies*/
              /*WebUri uri = WebUri(pageUrl);
              List<Cookie> cookies = await _cookieManager.getCookies(url: uri);
              final HashMap<String, String> hashMap = HashMap();
              for (var cookie in cookies) {
                // LoggerUtils.logger
                //     .d("WebViewController:cookies: ${cookie.name} : ${cookie.value}");
                hashMap.addIf(false, cookie.name, cookie.value);
              }
              PrefUtils.saveString(
                  PrefUtils.PREF_KEY_COOKIES, json.encode(hashMap));*/

              Uri uri = Uri.parse(pageUrl);
              if (uri.queryParameters.containsKey("code")) {
                LoggerUtils.logger
                    .d("initStateCode: ${uri.queryParameters["code"]}");
                widget.accessTokenCallback(uri.queryParameters["code"]);
                /*getAccessTokenFromCode(
                    uri.queryParameters["code"].toString()));*/
              }
              /*for (var key in uri.queryParameters.keys) {
                if (key.contains("code")) {
                  getAccessTokenFromCode(
                      uri.queryParameters["code"].toString());
                  break;
                } else if (key.contains("u")) {
                  Uri redirectUri =
                      Uri.parse(uri.queryParameters["u"].toString());
                  String code = redirectUri.queryParameters["code"].toString();
                  getAccessTokenFromCode(code);
                  break;
                }
              }*/
            },
            onHttpError: (HttpResponseError error) {
              LoggerUtils.logger
                  .e("HttpResponseError: " + (error.response.toString()));
            }))
        ..loadRequest(Uri.parse(InstagramAPI.getAuthRequestUrl()));
    } else {
      controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadRequest(Uri.parse(widget.postUrl));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.fromLTRB(20, 50, 20, 50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IconButton(
                alignment: Alignment.topRight,
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close)),
            Expanded(child: WebViewWidget(controller: controller))
          ],
        ));
  }

  void getAccessTokenFromCode(String code) {
    Map<String, String> params = HashMap<String, String>();
    params["client_id"] = APIConstants.INSTA_CLIENT_ID;
    params["client_secret"] = APIConstants.CLIENT_SECRET;
    params["grant_type"] = "authorization_code";
    params["redirect_uri"] = APIConstants.REDIRECT_URL;
    params["code"] = code;
    LoggerUtils.logger.d("getAccessTokenFromCode:Params $params");

    InstagramAPI.getAccessTokenFromCode(context, params,
        accessTokenCallback: (response, position, type) async {
      if (position == 0 && response != null) {
        HashMap<String, dynamic> jsonObject = json.decode(response);
        if (jsonObject.containsKey("access_token")) {
          onTokenReceived(jsonObject["user_id"], jsonObject["access_token"]);
        }
      } else {
        Fluttertoast.showToast(msg: "Login error!");
      }
    });
  }

  void onTokenReceived(String userId, String authToken) {
    if (authToken == null || authToken.isEmpty) return;
    PrefUtils.saveString(PrefUtils.PREF_KEY_ACCESS_TOKEN, authToken);
    PrefUtils.saveString(PrefUtils.PREF_KEY_USER_ID, userId);
    getUserInfoByAccessToken(userId, authToken.toString());
  }

  void getUserInfoByAccessToken(String userId, String authToken) {
    InstagramAPI.getUserInfo(userId, authToken,
        userInfoCallback: (response, position, type) {
      if (position == 0) {
        if (response != null) {
          HashMap<String, dynamic> jsonMap = json.decode(response);
          try {
            if (jsonMap.containsKey("id")) {
              PrefUtils.saveString(PrefUtils.PREF_KEY_USER_ID, jsonMap["id"]);
              PrefUtils.saveString(
                  PrefUtils.PREF_KEY_USER_NAME, jsonMap["username"]);
              Fluttertoast.showToast(msg: jsonMap["username"]);
            }
          } catch (error) {}
        } else {
          Fluttertoast.showToast(msg: "Login error!");
        }
      }
    });
  }
}
