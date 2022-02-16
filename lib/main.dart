import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:huawei_ml_body/huawei_ml_body.dart';

List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  cameras = await availableCameras();
  runApp(MaterialApp(home: MyHome()));
}

class MyHome extends StatefulWidget {
  MyHome({Key key}) : super(key: key);

  static Future<ui.Image> bytesToImage(Uint8List imgBytes) async {
    ui.Codec codec = await ui.instantiateImageCodec(imgBytes);
    ui.FrameInfo frame = await codec.getNextFrame();
    return frame.image;
  }

  @override
  _MyHomeState createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  final MLLivenessCapture _mlLivenessCapture = MLLivenessCapture();

  Image _finalImage;

  var _bytes;
  bool showImage = false;

  @override
  Widget build(BuildContext context) {
    // _bytes != null ? showImage = true : showImage = true;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Center(
              child: InkWell(
                onTap: () async {
                  MLLivenessCaptureResult okay =
                      await _mlLivenessCapture.startDetect();
                  print("okay is ${okay.score}");
                  print("okay is ${okay.bitmap}");
                  print("okay is ${okay.pitch}");
                  print("okay is ${okay.roll}");
                  print("okay is ${okay.yaw}");

                  var image = await MyHome.bytesToImage(okay.bitmap);

                  setState(() {
                    _bytes = okay.bitmap;
                    showImage = true;
                  });
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (_) => CameraApp(
                  //               cameras: cameras,
                  //             )));
                },
                child: Container(
                  color: Colors.amberAccent.withOpacity(0.5),
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Text(
                    'click here',
                    style: TextStyle(fontSize: 30),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            showImage
                ? Center(
                    child: InkWell(
                      onTap: () async {},
                      child: Container(
                          color: Colors.amberAccent.withOpacity(0.5),
                          padding:
                              EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                          child: Image.memory(
                            _bytes,
                            height: 400,
                            width: 400,
                          )),
                    ),
                  )
                : SizedBox(),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text("Test"),
      ),
    );
  }
}
