import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'camera_screen.dart'; // Import your screen

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Action Recognition App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: CameraScreen(cameras : cameras), // Start here
    );
  }
}