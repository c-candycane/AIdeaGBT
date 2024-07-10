import 'dart:async';
import 'dart:convert';
import 'package:aideagbt/AppUtilities.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final StreamController<String> _streamController = StreamController<String>();
  List<Map<String, String>> messages = []; // Message list to keep track of who sent the message
  String _temporaryResponse = ''; // Geçici mesaj birleştirme için değişken
  bool _isTempMessageAdded = false; // Geçici mesaj eklenip eklenmediğini takip etmek için

  @override
  void dispose() {
    _controller.dispose();
    _streamController.close();
    super.dispose();
  }

  Future<void> _sendPrompt(String prompt) async {
    setState(() {
      messages.add({'role': 'user', 'content': prompt}); // Add user message to the list
    });

    final url = Uri.parse('http://10.0.2.2:5000/chat'); // Use 10.0.2.2 for Android emulator
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'prompt': prompt});

    try {
      final request = http.Request('POST', url)
        ..headers.addAll(headers)
        ..body = body;

      final client = http.Client();
      final response = await client.send(request);

      response.stream.transform(utf8.decoder).listen((value) {
        setState(() {
          _temporaryResponse += value;

          if (!_isTempMessageAdded) {
            messages.add({'role': 'assistant', 'content': ''});
            _isTempMessageAdded = true;
          }

          messages.last['content'] = _temporaryResponse;

          if (_temporaryResponse.contains('/end/')) {
            messages.last['content'] = _temporaryResponse.replaceAll('/end/', '');
            _temporaryResponse = '';
            _isTempMessageAdded = false;
          }

          _streamController.add(messages.last['content']!);
        });
      }).onDone(() {
        client.close();
      });
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect to the server.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Streaming Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return ListTile(
                  title: Align(
                    alignment: message['role'] == 'user' ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                      decoration: BoxDecoration(
                        color: message['role'] == 'user' ? Colors.green : Colors.blue,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(message['content']!),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(labelText: 'AIdeaGBT\'ye ileti gönder',labelStyle:AppUtilities.primaryTextStyleWhiteSmall),
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        _sendPrompt(value);
                        _controller.clear();
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      _sendPrompt(_controller.text);
                      _controller.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
