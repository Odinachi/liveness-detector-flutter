import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraApp extends StatefulWidget {
  List<CameraDescription> cameras;
  CameraApp({this.cameras});
  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  CameraController controller;
  bool _snap = false;
  @override
  void initState() {
    super.initState();
    controller =
        CameraController(widget.cameras[1], ResolutionPreset.ultraHigh);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });

    // if (!mounted) {
    //   return;
    // }
  }

  @override
  void dispose() {
    controller?.dispose();
    controller.stopImageStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("camera is ${widget.cameras.asMap()}");
    if (!controller.value.isInitialized) {
      return Container();
    }
    return Column(
      children: [
        Expanded(flex: 8, child: CameraPreview(controller)),
        Expanded(
          child: Container(
            color: Colors.red,
            child: GestureDetector(
              onTap: () async {
                var x = await controller.takePicture();
              },
              child: Container(
                decoration:
                    BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                height: 300,
                width: 300,
              ),
            ),
          ),
        )
      ],
    );
  }
}
