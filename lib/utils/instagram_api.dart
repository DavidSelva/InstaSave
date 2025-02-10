import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:instasave/utils/constants.dart';
import 'package:instasave/utils/logger_utils.dart';

class InstagramAPI {
  static String getRequestUrl() {
    StringBuffer buffer = StringBuffer();
    buffer.write(APIConstants.BASE_URL);
    buffer.write("oauth/authorize/");
    buffer.write("?client_id=");
    buffer.write(APIConstants.CLIENT_ID);
    buffer.write("&redirect_uri=");
    buffer.write(APIConstants.REDIRECT_URL);
    buffer.write("&scope=user_profile");
    buffer.write("&response_type=code");
    LoggerUtils.logger.d("getRequestUrl: $buffer");
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

  static void getUserInfo(String userId, String authToken,
      {required Function userInfoCallback}) async {
    StringBuffer postUrl = StringBuffer();
    postUrl.write(APIConstants.USER_INFO_GRAPH_URL);
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
}
