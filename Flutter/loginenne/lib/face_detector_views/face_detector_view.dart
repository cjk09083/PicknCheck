import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'camera_view.dart';
import 'face_detector_painter.dart';

class FaceDetectorView extends StatefulWidget {
  @override
  _FaceDetectorViewState createState() => _FaceDetectorViewState();
}

class _FaceDetectorViewState extends State<FaceDetectorView> {
  FaceDetector faceDetector =
      GoogleMlKit.vision.faceDetector(FaceDetectorOptions(
    enableContours: true,
    enableClassification: true,
  ));
  bool isBusy = false;
  CustomPaint? customPaint;

  @override
  void dispose() {
    faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CameraView(
      title: 'Face Detector',
      customPaint: customPaint,
      onImage: (inputImage) {
        processImage(inputImage);
      },
    );
  }

  Future<void> processImage(InputImage inputImage) async {
    if (isBusy) return;
    isBusy = true;

    final faces = await faceDetector.processImage(inputImage);
    print('Found ${faces.length} faces');
    if(faces.isNotEmpty){
      print('face top:${faces[0].boundingBox.top} ');
      print('face bottom:${faces[0].boundingBox.bottom} ');
      print('face left:${faces[0].boundingBox.left} ');
      print('face right:${faces[0].boundingBox.right} ');
      print('face box:${faces[0].boundingBox.size} ');



    }
    if (inputImage.inputImageData?.size != null &&
        inputImage.inputImageData?.imageRotation != null) {
      print('Live painter');
      print('face size: ${inputImage.inputImageData?.size} ');
      print('face imageRotation: ${inputImage.inputImageData?.imageRotation} ');
      final painter = FaceDetectorPainter(
          faces,
          inputImage.inputImageData!.size,
          inputImage.inputImageData!.imageRotation);
      customPaint = CustomPaint(painter: painter);
    } else {
      if(faces.isNotEmpty ) {
        final String path = inputImage.filePath!;
        print('Gallery painter path : ${inputImage.filePath}');

        File imageFile = File(path);
        // print('File path : ${imageFile.path}');
        int fileLength = await imageFile.length();
        // print('File length : ${fileLength}');

        final decodedImage = await decodeImageFromList(imageFile.readAsBytesSync());
        // final Size size = Size(decodedImage.height.toDouble(), decodedImage.width.toDouble());
        double wRatio = decodedImage.width / 300;
        double hRatio = decodedImage.height / 300;

        final Size size = Size(decodedImage.width.toDouble(),
            decodedImage.height.toDouble());

        print('image size : $size');
        // print('imageRotation: ${InputImageRotation.Rotation_0deg} ');
        final painter = FaceDetectorPainter(
            faces,
            size,
            InputImageRotation.Rotation_0deg);
        customPaint = CustomPaint(painter: painter);
      }else{
        customPaint = null;
      }
    }
    isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}
