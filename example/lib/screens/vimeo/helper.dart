// used to get valid vimeo video configuration
import 'package:dio/dio.dart';
import 'package:example/screens/vimeo/vimeo_video_config.dart';

String? convertUrlToId(String url, {bool trimWhitespaces = true}) {
  if (!url.contains("http") && (url.length <= 11)) return url;
  if (trimWhitespaces) url = url.trim();

  for (var exp in [
    RegExp(r"^https?:\/\/(?:www\.|player\.)?vimeo.com\/(?:channels\/(?:\w+\/)?|groups\/([^\/]*)\/videos\/|album\/(\d+)\/video\/|video\/|)(\d+)(?:$|\/|\?)(?:[?]?.*)$",
        caseSensitive: false, multiLine: false),
  ]) {
    Match? match = exp.firstMatch(url);
    if (match != null && match.groupCount >= 1) return match.group(3);
  }

  var vimeoId = url;
  vimeoId = vimeoId.split("vimeo.com/").last;
  if (vimeoId.contains("video/")) {
    vimeoId = vimeoId.split("video/").last;
    if (vimeoId.contains("/")) {
      vimeoId = vimeoId.split("/").first;
    }
  } else if (vimeoId.contains("event/")) {
    vimeoId = vimeoId.split("event/").last;
    if (vimeoId.contains("/")) {
      vimeoId = vimeoId.split("/").first;
    }
  } else {
    vimeoId = vimeoId.split("/").first;
  }
  return RegExp(r'(\d+)').firstMatch(vimeoId)?.group(1);
}

Future<VimeoVideoConfig?> getVimeoVideoConfigFromUrl(
  String url, {
  bool trimWhitespaces = true,
}) async {
  if (trimWhitespaces) url = url.trim();

  /// here i'm converting the vimeo video id only and calling config api for vimeo video .mp4
  /// supports this types of urls
  /// https://vimeo.com/70591644 => 70591644
  /// www.vimeo.com/70591644 => 70591644
  /// vimeo.com/70591644 => 70591644
  var vimeoVideoId = convertUrlToId(url, trimWhitespaces: trimWhitespaces);
  if (vimeoVideoId != null && vimeoVideoId.isNotEmpty) {
    final response = await _getVimeoVideoConfig(vimeoVideoId: vimeoVideoId);
    return response;
  }

  var videoIdGroup = 4;
  for (var exp in [
    RegExp(r"^((https?):\/\/)?(www.)?vimeo\.com\/([0-9]+).*$"),
  ]) {
    RegExpMatch? match = exp.firstMatch(url);
    if (match != null && match.groupCount >= 1) {
      vimeoVideoId = match.group(videoIdGroup) ?? '';
    }
  }

  final response = await _getVimeoVideoConfig(vimeoVideoId: vimeoVideoId!);
  return (response != null) ? response : null;
}

/// give vimeo video configuration from api
Future<VimeoVideoConfig?> _getVimeoVideoConfig({required String vimeoVideoId}) async {
  try {
    Response responseData = await Dio().get(
      'https://player.vimeo.com/video/$vimeoVideoId/config',
    );
    var vimeoVideo = VimeoVideoConfig.fromJson(responseData.data);
    return vimeoVideo;
  } on DioError catch (e) {
    print('Dio Error e.error.toString()');
    return null;
  } on Exception catch (e) {
    print('Error :  e.toString()');
    return null;
  }
}

void _videoPlayer(String url) {
  /// getting the vimeo video configuration from api and setting managers
  getVimeoVideoConfigFromUrl(url).then((value) {
    final progressiveList = value?.request?.files?.progressive;

    var vimeoMp4Video = '';

    if (progressiveList != null && progressiveList.isNotEmpty) {
      progressiveList.map((element) {
        if (element != null && element.url != null && element.url != '' && vimeoMp4Video == '') {
          vimeoMp4Video = element.url ?? '';
        }
      }).toList();
      //vimeoMp4Video == '' ? showAlertDialog(context) : null;
    }
  });
}
