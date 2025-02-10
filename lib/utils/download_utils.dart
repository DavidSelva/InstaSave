class DownloadUtils {
  static const String GRAPHQL_URL = "https://graph.instagram.com/";
  static const String INSTA_END_POINT_ONE = "__a=1&__d=dis";
  static const String INSTA_END_POINT_TWO = "__a=1&__d=1";

  static String getGraphUrl(String postUrl) {
    if (postUrl.contains("?") == true) {
      return "$postUrl&$INSTA_END_POINT_ONE";
    } else {
      return "$postUrl?$INSTA_END_POINT_TWO";
    }
  }
}
