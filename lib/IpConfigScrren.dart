import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IpConfigScreen extends StatefulWidget {
  const IpConfigScreen({Key? key}) : super(key: key);

  @override
  State<IpConfigScreen> createState() => _IpConfigScreenState();
}

class _IpConfigScreenState extends State<IpConfigScreen> {
  TextEditingController ipController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedIp();
  }

  Future<void> _loadSavedIp() async {
    final prefs = await SharedPreferences.getInstance();
    ipController.text = prefs.getString('server_ip') ?? '';
  }

  Future<void> _saveIp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('server_ip', ipController.text);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('IP Saved!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Set Backend IP")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: ipController,
              decoration: InputDecoration(labelText: 'Enter backend IP'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveIp,
              child: Text("Save"),
            )
          ],
        ),
      ),
    );
  }
}
