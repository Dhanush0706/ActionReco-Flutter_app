import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;
import 'prediction_screen.dart';

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CameraScreen({Key? key, required this.cameras}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController controller;
  late Future<void> initializeControllerFuture;
  bool isRecording = false;
  XFile? videoFile;
  Timer? _timer;
  int _recordDuration = 0;

  @override
  void initState() {
    super.initState();
    controller = CameraController(widget.cameras[0], ResolutionPreset.high);
    initializeControllerFuture = controller.initialize();
  }

  @override
  void dispose() {
    controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _recordDuration = 0;
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      setState(() {
        _recordDuration++;
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _recordDuration = 0;
    });
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }

  Future<void> _startRecording() async {
    try {
      await initializeControllerFuture;
      final directory = await getTemporaryDirectory();
      final videoPath = join(
        directory.path,
        '${DateTime.now().millisecondsSinceEpoch}.mp4',
      );
      await controller.startVideoRecording();
      _startTimer();
      setState(() {
        isRecording = true;
      });
    } catch (e) {
      print('Error starting video recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      final file = await controller.stopVideoRecording();
      _stopTimer();
      setState(() {
        isRecording = false;
        videoFile = file;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PredictionScreen(videoPath: videoFile!.path),
        ),
      );
    } catch (e) {
      print('Error stopping video recording: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                Positioned.fill(
                  child: CameraPreview(controller),
                ),
                if (isRecording)
                  Positioned(
                    top: 40,
                    left: 20,
                    child: Row(
                      children: [
                        Icon(Icons.fiber_manual_record, color: Colors.red),
                        SizedBox(width: 8),
                        Text(
                          _formatDuration(_recordDuration),
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                Positioned(
                  bottom: 30,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: FloatingActionButton(
                      backgroundColor: isRecording ? Colors.red : Colors.green,
                      onPressed: isRecording ? _stopRecording : _startRecording,
                      child: Icon(isRecording ? Icons.stop : Icons.videocam),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
