import 'dart:math';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

detector(CameraDescription camera, CameraImage cameraImage) async {
  final InputImageRotation imageRotation =
      InputImageRotationMethods.fromRawValue(camera.sensorOrientation) ??
          InputImageRotation.Rotation_0deg;

  final InputImageFormat inputImageFormat =
      InputImageFormatMethods.fromRawValue(cameraImage.format.raw) ??
          InputImageFormat.NV21;

  final planeData = cameraImage.planes.map(
    (Plane plane) {
      return InputImagePlaneMetadata(
        bytesPerRow: plane.bytesPerRow,
        height: plane.height,
        width: plane.width,
      );
    },
  ).toList();

  final Size imageSize =
      Size(cameraImage.width.toDouble(), cameraImage.height.toDouble());
  final WriteBuffer allBytes = WriteBuffer();
  for (Plane plane in cameraImage.planes) {
    allBytes.putUint8List(plane.bytes);
  }
  final bytes = allBytes.done().buffer.asUint8List();
  final inputImageData = InputImageData(
    size: imageSize,
    imageRotation: imageRotation,
    inputImageFormat: inputImageFormat,
    planeData: planeData,
  );

  final inputImage =
      InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);

  // final poseDetector = GoogleMlKit.vision.poseDetector();
  final faceDetector = GoogleMlKit.vision.faceDetector(FaceDetectorOptions(
    mode: FaceDetectorMode.accurate,
  ));

  // final List<Pose> poses = await poseDetector.processImage(inputImage);
  final List<Face> faces = await faceDetector.processImage(inputImage);

  // for (Pose pose in poses) {
  //   // to access all landmarks
  //   pose.landmarks.forEach((_, landmark) {
  //     final type = landmark.type;
  //     final x = landmark.x;
  //     final y = landmark.y;
  //   });

  // to access specific landmarks
  // final landmark = pose.landmarks[PoseLandmarkType.nose];
  // }

  for (Face face in faces) {
    final Rect boundingBox = face.boundingBox;

    final double rotY =
        face.headEulerAngleY; // Head is rotated to the right rotY degrees
    print("head tilt Y is ${rotY}");

    final double rotZ =
        face.headEulerAngleZ; // Head is tilted sideways rotZ degrees
    print("head tilt Z is ${rotZ}");

    // If landmark detection was enabled with FaceDetectorOptions (mouth, ears,
    // eyes, cheeks, and nose available):
    final FaceLandmark leftEar = face.getLandmark(FaceLandmarkType.leftEar);
    if (leftEar != null) {
      final Point<double> leftEarPos = leftEar.position as Point<double>;
      print("left ears probability is ${leftEarPos.toString()}");
    }

    // If classification was enabled with FaceDetectorOptions:
    if (face.smilingProbability != null) {
      final double smileProb = face.smilingProbability;
      print("Smile probability is ${smileProb}");
    }

    // If face tracking was enabled with FaceDetectorOptions:
    if (face.trackingId != null) {
      final int id = face.trackingId;
    }
  }
}
