import 'dart:collection';
import 'dart:convert';

import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/state_manager.dart';
import 'package:http/http.dart' as http;
import 'package:instasave/utils/constants.dart';
import 'package:instasave/utils/download_utils.dart';
import 'package:instasave/utils/logger_utils.dart';
import 'package:instasave/utils/pref_utils.dart';

class InstagramAPI {
  static String getAuthRequestUrl() {
    StringBuffer buffer = StringBuffer();
    buffer.write(APIConstants.BASE_URL);
    buffer.write("oauth/authorize/");
    buffer.write("?client_id=");
    buffer.write(APIConstants.INSTA_CLIENT_ID);
    buffer.write("&redirect_uri=");
    buffer.write(APIConstants.REDIRECT_URL);
    buffer.write("&scope=instagram_business_basic");
    buffer.write("&response_type=code");
    buffer.write("&hl=en");
    LoggerUtils.logger.d("getAuthRequestUrl: $buffer");
    return buffer.toString();
  }

  static void getAccessTokenFromCode(
      BuildContext context, Map<String, String> params,
      {required Function accessTokenCallback}) async {
    final response =
        await http.post(Uri.parse(APIConstants.GET_ACCESS_TOKEN_URL));
    if (response.statusCode == 200) {
      accessTokenCallback(response.body, 0, Constants.KEY_TOKEN);
    }
  }

  static Future<Map<String, dynamic>> getTokenAndUserID({required code}) async {
    Map<String, String> params = HashMap<String, String>();
    params.addIf(true, "client_id", APIConstants.INSTA_CLIENT_ID);
    params.addIf(true, "client_secret", APIConstants.INSTA_CLIENT_APP_SECRET);
    params.addIf(true, "grant_type", "authorization_code");
    params.addIf(true, "redirect_uri", APIConstants.REDIRECT_URL);
    params.addIf(true, "code", code);
    LoggerUtils.logger.d("getTokenAndUserIDParams: ${params}");

    final response = await http
        .post(Uri.parse(APIConstants.GET_ACCESS_TOKEN_URL), body: params);
    LoggerUtils.logger.d("getTokenAndUserID: ${response.body}");
    Map<String, dynamic> responseMap = jsonDecode(response.body);
    if (response.statusCode == 200) {
      PrefUtils.saveString(
          PrefUtils.PREF_KEY_ACCESS_TOKEN, responseMap["access_token"]);
      PrefUtils.saveString(
          PrefUtils.PREF_KEY_USER_ID, responseMap["user_id"].toString());
      return responseMap;
    } else {
      if (response.statusCode == 400 &&
          responseMap["error_message"] ==
              "This authorization code has been used") {
        return HashMap();
      } else {
        return HashMap();
      }
    }
  }

  static void getUserInfo(String userId, String authToken,
      {required Function userInfoCallback}) async {
    StringBuffer postUrl = StringBuffer();
    postUrl.write(APIConstants.INSTA_GRAPH_URL);
    postUrl.write(userId);
    postUrl.write("?fields=id,username");
    postUrl.write("&access_token=");
    postUrl.write(authToken);
    LoggerUtils.logger.d("getUserInfo: $postUrl");
    final response = await http.post(Uri.parse(postUrl.toString()));
    if (response.statusCode == 200) {
      userInfoCallback(response, 0, Constants.KEY_URL);
    } else {
      Fluttertoast.showToast(msg: "Invalid Url");
      userInfoCallback(null, -1, Constants.KEY_URL);
    }
  }

  static void getUserInfoUsingToken(String? accessToken,
      {required Function userInfoCallback}) async {
    StringBuffer postUrl = StringBuffer();
    postUrl.write(APIConstants.FACEBOOK_USER_INFO_GRAPH_URL);
    postUrl.write(APIConstants.INSTA_URL_VERSION);
    postUrl.write("accounts");
    postUrl.write("?access_token=");
    postUrl.write(accessToken);
    LoggerUtils.logger.d("getUserInfoUsingToken: $postUrl");
    final response = await http.get(Uri.parse(postUrl.toString()));
    if (response.statusCode == 200) {
      LoggerUtils.logger.d("getUserInfoUsingTokenResponse: ${response.body}");
      userInfoCallback(response, 0, Constants.KEY_URL);
    } else {
      LoggerUtils.logger.e("getUserInfoUsingTokenError: ${response.body}");
      userInfoCallback(null, -1, Constants.KEY_URL);
    }
  }

  static String getFeedGraphUrl(String postUrl) {
    if (postUrl.contains("?") == true) {
      return "$postUrl&${DownloadUtils.INSTA_END_POINT_ONE}";
    } else {
      return "$postUrl?${DownloadUtils.INSTA_END_POINT_TWO}";
    }
  }

  static Future<String> getAuthorization() async {
    Uri loginUrl = Uri.parse(InstagramAPI.getAuthRequestUrl());
    final response = await http.get(Uri.parse(loginUrl.toString()));
    if (response.statusCode == 200) {
      LoggerUtils.logger.d("getAuthorizationResponse: ${response.body}");
      return response.body;
    } else {
      LoggerUtils.logger.e("getAuthorizationError: ${response.body}");
      return "";
    }
  }

  static Future<Map<String, dynamic>> getDownloadInfo(
      String? accessToken, String feedGraphUrl) async {
    LoggerUtils.logger.d("getDownloadInfoUrl: $feedGraphUrl");
    final response = await http.post(Uri.parse(feedGraphUrl.toString()));
    if (response.statusCode == 200) {
      LoggerUtils.logger.d("getDownloadInfo: ${response.body}");
      var responseMap = jsonDecode(response.body);
      return responseMap;
    } else {
      Fluttertoast.showToast(msg: "Invalid Url");
      LoggerUtils.logger.e("getDownloadInfo: ${response.body}");
      var responseMap = jsonDecode(response.body);
      return responseMap;
    }
  }

  static void getLongLiveToken(Map<String, dynamic> shortToken,
      {required Function accessTokenCallback}) async {
    StringBuffer postUrl = StringBuffer();
    postUrl.write(APIConstants.INSTA_GRAPH_URL);
    postUrl.write("access_token");
    postUrl.write("?grant_type=ig_exchange_token");
    postUrl.write("&client_secret=");
    postUrl.write(APIConstants.INSTA_CLIENT_APP_SECRET);
    postUrl.write("&access_token=");
    postUrl.write(shortToken["access_token"]);
    LoggerUtils.logger.d("getLongLiveTokenUrl: $postUrl");
    final response = await http.get(Uri.parse(postUrl.toString()));
    if (response.statusCode == 200) {
      LoggerUtils.logger.d("getLongLiveTokenResponse: ${response.body}");
      var responseMap = jsonDecode(response.body);
      PrefUtils.saveString(
          PrefUtils.PREF_KEY_ACCESS_TOKEN, responseMap["access_token"]);
      PrefUtils.saveDouble(PrefUtils.PREF_KEY_ACCESS_TOKEN_EXPIRY,
          double.parse(responseMap["expires_in"].toString()));
      accessTokenCallback(response.statusCode, response.body);
    } else {
      LoggerUtils.logger.e("getLongLiveTokenError: ${response.body}");
      accessTokenCallback(response.statusCode, response.body);
    }
  }

  static void getInstaUserID(String accessToken,
      {required Function accessTokenCallback}) async {
    StringBuffer postUrl = StringBuffer();
    postUrl.write(APIConstants.INSTA_GRAPH_URL);
    postUrl.write(APIConstants.INSTA_URL_VERSION);
    postUrl.write("?fields=user_id,username");
    postUrl.write("&access_token=");
    postUrl.write(accessToken);
    LoggerUtils.logger.d("getInstaUserName: $postUrl");
    final response = await http.get(Uri.parse(postUrl.toString()));
    if (response.statusCode == 200) {
      LoggerUtils.logger.d("getInstaUserNameResponse: ${response.body}");
      Map<String, dynamic> responseMap = jsonDecode(response.body);
      PrefUtils.saveString(PrefUtils.PREF_KEY_ID, responseMap["id"]);
      PrefUtils.saveString(PrefUtils.PREF_KEY_USER_ID, responseMap["user_id"]);
      PrefUtils.saveString(
          PrefUtils.PREF_KEY_USER_NAME, responseMap["username"]);
      accessTokenCallback(response.statusCode, response.body);
    } else {
      accessTokenCallback(response.statusCode, response.body);
    }
  }
}
