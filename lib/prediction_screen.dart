import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PredictionScreen extends StatefulWidget {
  final String videoPath;

  const PredictionScreen({Key? key, required this.videoPath}) : super(key: key);

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  String? prediction;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    resolveIpAndUploadVideo();
  }

  Future<void> resolveIpAndUploadVideo() async {
    try {
      // Step 1: Get the IP from the domain (dkdi.com)
      final ipResponse = await http.get(Uri.parse('https://server-manager-shzh.onrender.com/get-gpu-ip/')); // 🟡 Your API must return {"ip": "1.2.3.4"}
      if (ipResponse.statusCode == 200) {
        final ipData = json.decode(ipResponse.body);
        final ipAddress = ipData['gpu_server_ip'];
        print(ipAddress);
        await uploadVideo(ipAddress);
      } else {
        setState(() {
          prediction = "Failed to get IP address: ${ipResponse.statusCode}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        prediction = "Error fetching IP: $e";
        isLoading = false;
      });
    }
  }

  Future<void> uploadVideo(String ip) async {
  try {
    final uri = Uri.parse('http://$ip:12345/api/'); 
    final request = http.MultipartRequest('POST', uri);
    request.files.add(
      await http.MultipartFile.fromPath('video', widget.videoPath),
    );

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await http.Response.fromStream(response);
      final data = json.decode(responseData.body);

      // Extract and format prediction map
      final labelMap = Map<String, dynamic>.from(data['label']);
      final formattedPrediction = labelMap.entries
          .map((entry) => "${entry.key}: ${entry.value}")
          .join("\n");

      setState(() {
        prediction = formattedPrediction;
        isLoading = false;
      });
    } else {
      setState(() {
        prediction = "Server Error: ${response.statusCode}";
        isLoading = false;
      });
    }
  } catch (e) {
    setState(() {
      prediction = "Upload failed: $e";
      isLoading = false;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Prediction")),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : Text(
                "Predicted Action:\n$prediction",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24),
              ),
      ),
    );
  }
}
