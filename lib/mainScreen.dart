import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:aideagbt/user_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import 'AppUtilities.dart';
import 'FirebaseUtilities.dart';
import 'chat_history_page.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;

class mainScreen extends StatefulWidget {
  const mainScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<mainScreen> createState() => _mainScreenState();
}

class _mainScreenState extends State<mainScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String username = "";
  final TextEditingController _controller = TextEditingController();
  final StreamController<String> _streamController = StreamController<String>();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, String>> messages = [];
  String _temporaryResponse = '';
  bool _isTempMessageAdded = false;
  bool _isLoading = false;
  var url;
  var ipAdressGlobal;
  String currentChatId = '';
  bool _isNewChat = true;
  File? _selectedFile;
  String? _selectedFileName;
  String? _selectedFileType; // Eklendi: Seçilen dosya türünü saklayacak değişken

  @override
  void dispose() {
    _controller.dispose();
    _streamController.close();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fetchUsername();
    _fetchIpAddress();
    //_startNewChat();
  }

  void fetchUsername() async {
    username = await UserUtilities.getUserName();
    setState(() {});
  }

  Future<void> _startNewChat(String prompt, String? fileUrl) async {
    try {
      currentChatId = DateTime.now().millisecondsSinceEpoch.toString();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(UserUtilities.getCurrentUserUid() ?? '')
            .collection('chat_history')
            .doc(currentChatId)
            .set({
          'timestamp': DateTime.now(),
          'messages': [
            {
              'role': 'user',
              'content': prompt,
              if (_selectedFileType != null && _selectedFileType == "image" &&
                  fileUrl != null) 'images': fileUrl,
              if (_selectedFileType != null && _selectedFileType != "image" &&
                  fileUrl != null) 'files': fileUrl,
            }
          ],
          'chat_title': prompt,
        });

        setState(() {
          messages.clear();
          messages.add({
            'role': 'user',
            'content': prompt,
            if (_selectedFileType != null && _selectedFileType == "image" &&
                fileUrl != null) 'images': fileUrl,
            if (_selectedFileType != null && _selectedFileType != "image" &&
                fileUrl != null) 'files': fileUrl,
          });
          _isNewChat = false;
          _streamController.add('');
        });


    } catch (e) {
      print('Error starting new chat: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Yeni sohbet başlatılamadı: $e')),
      );
    }
  }

  Future<String> uploadFileToFirebase(File file) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageRef = FirebaseStorage.instance.ref().child('files/$fileName');
      UploadTask uploadTask = storageRef.putFile(file);
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading file: $e');
      return '';
    }
  }

  Future<void> updateChat(String userUid, String chatId, List<Map<String, String>> chatHistory) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userUid)
        .collection('chat_history')
        .doc(chatId)
        .update({
      'timestamp': DateTime.now(),
      'messages': chatHistory,
    });
  }

  Future<void> _sendPrompt(String prompt) async {
    await _fetchIpAddress();
    String userUid = UserUtilities.getCurrentUserUid() ?? '';
    setState(() {
      _isLoading = true;
    });
    String? fileUrl;
    if (_selectedFile != null) {
      fileUrl = await uploadFileToFirebase(_selectedFile!);
      if (fileUrl.isEmpty) {
        print('Error uploading file.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Dosya yüklenemedi.')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }
    }

    // Check if any message contains 'files'
    bool containsFiles = messages.any((message) => message.containsKey('files') || message.containsKey('images'));

    String endpoint = (fileUrl != null || containsFiles) ? '/chat_vision' : '/chat'; // Decide endpoint based on presence of file in messages or the current prompt
    print('Endpoint: ${endpoint}');
    if (_isNewChat) {
      await _startNewChat(prompt, fileUrl);
    } else {

      setState(() {
        messages.add({
          'role': 'user',
          'content': prompt,
          if (_selectedFileType != null && _selectedFileType == "image" &&
              fileUrl != null) 'images': fileUrl,
          if (_selectedFileType != null && _selectedFileType != "image" &&
              fileUrl != null) 'files': fileUrl,
        });
      });
    }

    setState(() {
      _selectedFile = null;
      _selectedFileName = null;
      _selectedFileType = null; // Eklendi: Seçilen dosya türünü sıfırla
    });

    List<Map<String, String>> chatHistory = List.from(messages); // Clone the messages list
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'prompt': prompt,
      'userUid': userUid,
      'chatHistory': chatHistory,
    });

    Uri requestUrl = Uri.parse('$url$endpoint'); // Construct request URL with correct endpoint
    print(requestUrl);

    try {
      final request = http.Request('POST', requestUrl)
        ..headers.addAll(headers)
        ..body = body;

      final client = http.Client();
      final response = await client.send(request);

      response.stream.transform(utf8.decoder).listen((value) async {
        if (_isLoading) {
          setState(() {
            _isLoading = false; // Set loading to false as soon as response starts
          });
        }
        _temporaryResponse += value;

        if (!_isTempMessageAdded) {
          setState(() {
            messages.add({'role': 'assistant', 'content': ''});
            _isTempMessageAdded = true;
          });
        }

        setState(() {
          messages.last['content'] = _temporaryResponse;
        });
        _scrollToBottom(); // Scroll to bottom when new content is added
        if (_temporaryResponse.contains('/end/')) {
          _temporaryResponse = _temporaryResponse.replaceAll('/end/', '');
          setState(() {
            messages.last['content'] = _temporaryResponse;
          });
          _temporaryResponse = '';
          updateChat(userUid, currentChatId, messages);
          _isTempMessageAdded = false;

          if (_isNewChat) {
            _isNewChat = false; //
          }
        }

        _streamController.add(messages.last['content']!);
      }).onDone(() {
        client.close();
      });

    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect to the server.')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchIpAddress() async {
    try {
      String uid = UserUtilities.getCurrentUserUid() ?? '';
      DocumentSnapshot<Map<String, dynamic>> userDoc =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userDoc.exists) {
        String ipAddress = userDoc['chat_ip'] ?? '';

        if (ipAddress.isNotEmpty) {
          setState(() {
            ipAdressGlobal = ipAddress;

            if (RegExp(r'^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$').hasMatch(ipAdressGlobal)) {
              url = 'http://$ipAdressGlobal:8000';
            } else {
              url = ipAdressGlobal;
            }
          });
        }
      }
    } catch (e) {
      print('Failed to fetch IP address: $e');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _selectedFileName = result.files.single.name;
        _selectedFileType = result.files.single.extension; // Eklendi: Dosya türünü sakla
        if (_selectedFileType != 'pdf'){
          _selectedFileType = 'image';
        }
      });
    }
  }

  Future<void> _selectImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedFile = File(image.path);
        _selectedFileName = image.name;
        _selectedFileType = image.mimeType; // Eklendi: Dosya türünü sakla
      });
    }
  }
  Future<void> _loadChatHistory(String chatId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(UserUtilities.getCurrentUserUid() ?? '')
          .collection('chat_history')
          .doc(chatId)
          .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data()!;
        List<dynamic> chatMessages = data['messages'] ?? [];
        setState(() {
          messages = chatMessages.map((message) => Map<String, String>.from(message)).toList();
          currentChatId = chatId;
          _isNewChat = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      print('Error loading chat history: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load chat history: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppUtilities.backgroundColor,
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UserPage()),
            );
          },
          child: Row(
            children: [
              Image.asset(
                AppUtilities.appLogoPath,
                height: 50,
                width: 50,
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppUtilities.appName),
                  Text(
                    "$username",
                    style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserPage()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              setState(() {
                _isNewChat = true; // Yeni sohbet başlatma durumu ayarla
                messages.clear();
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatHistoryScreen()),
              );
              if (result != null && result.containsKey('chatId')) {
                _loadChatHistory(result['chatId']);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.length + (_isLoading ? 1 : 0), // Add an extra item if loading
              itemBuilder: (context, index) {
                if (_isLoading && index == messages.length) {
                  // Show loading indicator
                  return ListTile(
                    title: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text("..."),
                      ),
                    ),
                  );
                } else {
                  final message = messages[index];
                  return ListTile(
                    title: Align(
                      alignment: message['role'] == 'user' ? Alignment.centerRight : Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: message['role'] == 'user' ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          if (message.containsKey('images'))
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Image.network(
                                message['images']!,
                                width: 300,
                                height: 300,
                                fit: BoxFit.cover,
                              ),
                            ),
                          if (message.containsKey('files'))
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Icon(
                                Icons.insert_drive_file,
                                color: Colors.white,
                                size: 50,
                              ),
                            ),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                            decoration: BoxDecoration(
                              color: message['role'] == 'user' ? Colors.green : Colors.blue,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Text(message['content']!),
                          ),
                          if (message['role'] == 'user')
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                username,
                                style: TextStyle(fontSize: 10, color: Colors.grey),
                              ),
                            ),
                          if (message['role'] == 'assistant')
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                AppUtilities.appModel,
                                style: TextStyle(fontSize: 10, color: Colors.grey),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
          ),
          if (_selectedFile != null) // Seçilen dosya veya resmi göster
            Container(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  if (_selectedFileType == 'image')
                    Image.file(
                      _selectedFile!,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    )
                  else
                    Icon(
                      Icons.insert_drive_file,
                      color: Colors.white,
                      size: 50,
                    ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _selectedFileName!,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        _selectedFile = null;
                        _selectedFileName = null;
                        _selectedFileType = null;
                      });
                    },
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.attach_file),
                  onPressed: () async {
                    await _selectFile(); // Dosya veya resim seçme işlemi

                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: AppUtilities.primaryTextStyleWhiteSmallItalic,
                    decoration: InputDecoration(
                      labelText: 'AIdeaGBT\'ye ileti gönder',
                      labelStyle: AppUtilities.primaryTextStyleWhiteSmall,
                    ),
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



  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
