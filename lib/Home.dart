import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'Controller/DownloadController.dart';
import 'DownloadedList.dart';
import 'GenrateVideoFromPath.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  DownloadController downloadController = Get.put(DownloadController());
  TextEditingController urlController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "Reels Downloader",
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: InkWell(
                onTap: () {
                  Get.to(DownloadedList());
                },
                child: const Icon(
                  Icons.download,
                  color: Colors.black,
                )),
          )
        ],
      ),
      body: Container(
        constraints: const BoxConstraints.expand(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: GetBuilder(
                  init: downloadController,
                  builder: (_) => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 200,
                          width: 150,
                          child: downloadController.path != null
                              ? GenerateVideoFromPath(
                                  downloadController.path ?? "")
                              : const Center(child: Text("No recent download")),
                        ),
                      ]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: TextField(
                  controller: urlController,
                  autocorrect: true,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 10),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(25),
                        ),
                      ),
                      filled: true,
                      hintStyle: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                      hintText: "Paste instagram reel link here",
                      fillColor: Colors.white70),
                ),
              ),
              Obx(
                () => SizedBox(
                  height: 100,
                  child: downloadController.processing.value
                      ? const Center(
                          child: CupertinoActivityIndicator(),
                        )
                      : Center(
                          child: InkWell(
                            onTap: () {
                              downloadController.downloadReal(
                                  urlController.text, context);
                            },
                            child: Container(
                              height: 40,
                              width: 150,
                              decoration: const BoxDecoration(
                                color: Colors.deepPurple,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(25),
                                ),
                              ),
                              child: const Center(
                                  child: Text(
                                "Download",
                                style: TextStyle(color: Colors.white),
                              )),
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(
                height: 200,
                child: Center(child: Text("Made in ❤️ with Flutter")),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
