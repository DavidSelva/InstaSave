import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:instasave/utils/constants.dart';
import 'package:instasave/utils/instagram_api.dart';
import 'package:instasave/utils/logger_utils.dart';

import '../utils/pref_utils.dart';

class InAppWebViewFragment extends StatefulWidget {
  final String postUrl;
  final Function accessTokenCallback;

  const InAppWebViewFragment(
      {super.key, required this.postUrl, required this.accessTokenCallback});

  @override
  State<InAppWebViewFragment> createState() => _InAppWebViewFragmentState();
}

class _InAppWebViewFragmentState extends State<InAppWebViewFragment> {
  late final InAppWebViewController? controller;

  late final CookieManager _cookieManager = CookieManager.instance();

  @override
  void initState() {
    super.initState();
    _cookieManager.deleteAllCookies();
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
            Expanded(
                child: InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri("https://google.com/")),
              /* onRenderProcessUnresponsive: (controller, uri) async {
                return WebViewRenderProcessAction.TERMINATE;
              },*/
              onPermissionRequest: (controller, request) async {
                return PermissionResponse(
                    resources: request.resources,
                    action: PermissionResponseAction.GRANT);
              },
              initialSettings: InAppWebViewSettings(
                  javaScriptEnabled: false,
                  domStorageEnabled: false,
                  iframeAllowFullscreen: true,
                  userAgent:
                      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36',
                  useHybridComposition: true,
                  useWideViewPort: false,
                  supportMultipleWindows: true,
                  preferredContentMode: UserPreferredContentMode.DESKTOP),
              onWebViewCreated: (InAppWebViewController webViewController) {
                controller = webViewController;
                controller?.loadUrl(
                    urlRequest: URLRequest(
                        allowsCellularAccess: true,
                        allowsConstrainedNetworkAccess: true,
                        cachePolicy:
                            URLRequestCachePolicy.RETURN_CACHE_DATA_ELSE_LOAD,
                        url: WebUri(
                            InstagramAPI.getAuthRequestUrl().toString())));
              },
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                var uri = navigationAction.request.url!;

                if (![
                  "http",
                  "https",
                  "file",
                  "chrome",
                  "data",
                  "javascript",
                  "about"
                ].contains(uri.scheme)) {}

                return NavigationActionPolicy.ALLOW;
              },
              onLoadStop: (controller, pageUrl) async {
                Uri uri = Uri.parse(pageUrl.toString());
                if (uri.queryParameters.containsKey("code")) {
                  widget.accessTokenCallback(uri.queryParameters["code"]);
                  /*getAccessTokenFromCode(
                    uri.queryParameters["code"].toString()));*/
                }
              },
            ))
          ],
        ));
  }

  void getAccessTokenFromCode(String code) {
    Map<String, String> params = HashMap<String, String>();
    params["client_id"] = APIConstants.INSTA_CLIENT_ID;
    params["client_secret"] = APIConstants.INSTA_CLIENT_APP_SECRET;
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
