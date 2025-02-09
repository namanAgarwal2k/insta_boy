import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart' as wb;
import '../model/insta_post_with_login.dart';
import '../model/insta_post_without_login.dart';
import 'instagram_login.dart';

class DownloadController extends GetxController {
  var processing = false.obs;
  bool isLogin = false;
  String? path;
  var box = GetStorage();
  Dio dio = Dio();
  Future<String?> _startDownload(String link, BuildContext context) async {
    // Asking for video storage permission
    await Permission.storage.request();
    isLogin = false;
    // Checking for Cookies
    final cookieManager = wb.WebviewCookieManager();
    final gotCookies =
        await cookieManager.getCookies('https://www.instagram.com/');
    // is Cookie found then set isLogin to true
    if (gotCookies.isNotEmpty) isLogin = true;

    // Build the url
    var linkParts = link.replaceAll(" ", "").split("/");
    var url = '${linkParts[0]}//${linkParts[2]}/${linkParts[3]}/${linkParts[4]}'
        "?__a=1&__d=dis";

    // Make Http requiest to get the download link of video
    var httpClient = HttpClient();
    String? videoURLLLLL;
    try {
      var request = await httpClient.getUrl(Uri.parse(url));
      for (var element in gotCookies) {
        request.cookies.add(Cookie(element.name, element.value));
      }
      print(request);
      var response = await request.close();
      print(response);
      if (response.statusCode == HttpStatus.ok) {
        var json = await response.transform(utf8.decoder).join();
        var data = jsonDecode(json);
        print(isLogin);
        if (isLogin) {
          InstaPostWithLogin postWithLogin = InstaPostWithLogin.fromJson(data);
          videoURLLLLL = postWithLogin.items?.first.videoVersions?.first.url;
        } else {
          InstaPostWithoutLogin post = InstaPostWithoutLogin.fromJson(data);
          videoURLLLLL = post.graphql?.shortcodeMedia?.videoUrl;
        }
      }
    } catch (exception) {
      log(exception.toString());
      // Login to instagram in case of Cookie expire or download any private account's video
      await Navigator.push(
          context, MaterialPageRoute(builder: (_) => InstaLogin()));
    }

    // Download video & save
    if (videoURLLLLL == null) {
      return null;
    } else {
      var appDocDir = await getTemporaryDirectory();
      String savePath = "${appDocDir.path}/temp.mp4";
      await dio.download(videoURLLLLL, savePath);
      final result =
          await ImageGallerySaver.saveFile(savePath, isReturnPathOfIOS: true);
      return result["filePath"];
    }
  }

  downloadReal(String link, BuildContext context) async {
    processing.value = true;
    try {
      path = null;
      update();
      await _startDownload(link, context).then((value) {
        if (value == null) throw Exception();
        path = value;
        update();
        List allVideosPath = box.read("allVideo") ?? [];
        allVideosPath.add(path);
        box.write("allVideo", allVideosPath);
      });
    } catch (e) {
      print('error');
    }
    processing.value = false;
  }
}
