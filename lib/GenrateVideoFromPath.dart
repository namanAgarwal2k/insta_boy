import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import 'VideoPlayer.dart';

class GenerateVideoFromPath extends StatefulWidget {
  final String path;
  const GenerateVideoFromPath(this.path, {super.key});
  @override
  GenerateVideoFromPathState createState() => GenerateVideoFromPathState();
}

class GenerateVideoFromPathState extends State<GenerateVideoFromPath> {
  var uint8list;
  bool loading = true;
  @override
  void initState() {
    generateThumb();
    super.initState();
  }

  generateThumb() async {
    await VideoThumbnail.thumbnailData(
      video: widget.path,
      imageFormat: ImageFormat.JPEG,
      maxWidth:
          300, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
      quality: 10,
    ).then((value) {
      setState(() {
        loading = false;
        uint8list = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: loading
          ? const CupertinoActivityIndicator()
          : InkWell(
              onTap: () {
                Get.to(VideoPlayer(widget.path));
              },
              child: Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                            image: MemoryImage(uint8list), fit: BoxFit.cover)),
                  ),
                  ClipOval(
                    child: Container(
                        color: Colors.black38,
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.play_arrow,
                            size: 30,
                            color: Colors.white,
                          ),
                        )),
                  )
                ],
              )),
    );
  }
}
