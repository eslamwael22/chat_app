import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class chatsPage extends StatefulWidget {
  const chatsPage({
    super.key,
    required this.recevierName,
    required this.recevierId,
  });
  final String recevierName, recevierId;

  @override
  State<chatsPage> createState() => _chatsPageState();
}

class _chatsPageState extends State<chatsPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final String currentUserId =
      FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String getChatId() {
    final ids = [currentUserId, widget.recevierId]..sort();
    return ids.join('_');
  }

  Future<void> sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final message = _messageController.text.trim();
    _messageController.clear();

    try {
      final chatId = getChatId();

      await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add({
        'senderId': currentUserId,
        'receiverId': widget.recevierId,
        'text': message,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // ✅ مهم
      appBar: AppBar(
        title: Text(
          widget.recevierName,
          style: TextStyle(fontSize: 20.sp),
        ),
      ),

      body: Column(
        children: [
          /// 🔥 الرسائل
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(getChatId())
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: SpinKitThreeBounce(
                      color: Colors.blueAccent,
                      size: 30.0,
                    ),
                  );
                }

                if (snapshot.hasData &&
                    snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No messages yet',
                      style: TextStyle(fontSize: 16.sp),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: EdgeInsets.all(16.r),
                  itemCount: snapshot.data?.docs.length ?? 0,
                  itemBuilder: (context, index) {
                    final messageData = snapshot.data!.docs[index]
                        .data() as Map<String, dynamic>;

                    final isSentByMe =
                        messageData['senderId'] == currentUserId;

                    final timestamp =
                        messageData['timestamp'] as Timestamp?;

                    final timeString = timestamp != null
                        ? DateFormat('h:mm a')
                            .format(timestamp.toDate())
                        : '...';

                    return Align(
                      alignment: isSentByMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 10.h,
                          horizontal: 14.w,
                        ),
                        margin:
                            EdgeInsets.symmetric(vertical: 4.h),
                        decoration: BoxDecoration(
                          color: isSentByMe
                              ? Colors.blueAccent
                              : Colors.grey[300],
                          borderRadius:
                              BorderRadius.circular(12.r),
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              messageData['text'] ?? '',
                              style: TextStyle(
                                color: isSentByMe
                                    ? Colors.black
                                    : Colors.black87,
                              ),
                            ),
                            SizedBox(height: 5.h),
                            Text(
                              timeString,
                              style: TextStyle(
                                color: isSentByMe
                                    ? Colors.black54
                                    : Colors.black45,
                                fontSize: 10.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          /// 🔥 input field (بديل bottomNavigationBar)
          SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 16.w, vertical: 10.h),
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        style: TextStyle(fontSize: 16.sp),
                        decoration: InputDecoration(
                          hintText: 'Type a message..',
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(20.r),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    IconButton(
                      onPressed: sendMessage,
                      icon: Icon(
                        Icons.send,
                        color: Colors.blue,
                        size: 30.r,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}