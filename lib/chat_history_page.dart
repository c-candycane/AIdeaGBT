import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'FirebaseUtilities.dart';

class ChatHistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sohbet Geçmişi'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(UserUtilities.getCurrentUserUid() ?? '')
            .collection('chat_history')
            .orderBy('timestamp', descending: true) // Tarihlerine göre yeniden eskiye sıralama
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Henüz bir sohbet geçmişi bulunamadı.'));
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot doc) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              Timestamp timestamp = data['timestamp'] as Timestamp;
              DateTime dateTime = timestamp.toDate();
              String chatId = doc.id;
              String? chatTitle = data['chat_title'] as String?;

              return ListTile(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chatTitle ?? 'Sohbet Başlangıç Tarihi: ${dateTime.day}/${dateTime.month}/${dateTime.year}',
                      style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.blue), // Başlık rengi mavi
                    ),
                    if (chatTitle != null)
                      Text(
                        'Sohbet Başlangıç Tarihi: ${dateTime.day}/${dateTime.month}/${dateTime.year}',
                        style: TextStyle(fontSize: 12.0, color: Colors.grey), // Tarih rengi gri
                      ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white),
                  onPressed: () async {
                    // Belirli bir sohbeti Firestore'dan sil
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(UserUtilities.getCurrentUserUid() ?? '')
                        .collection('chat_history')
                        .doc(chatId)
                        .delete();
                  },
                ),
                onTap: () {
                  Navigator.pop(context, {'chatId': chatId, 'chatTitle': chatTitle, 'timestamp': timestamp});
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
