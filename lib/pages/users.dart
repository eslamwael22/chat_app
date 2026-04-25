import 'package:chat_app/pages/chat_page.dart';
import 'package:chat_app/pages/sign_up.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Users extends StatelessWidget {
  const Users({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'USERS',
          style: TextStyle(
            color: Colors.blue,
            fontSize: 25.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => SignUp()),
              (route) => false,
            );
          },
          icon: const Icon(Icons.logout, color: Colors.black, size: 28,),
        ),
        backgroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SpinKitThreeBounce(
              color: const Color.fromARGB(255, 13, 60, 141),
              size: 30.0.r,
            );
          }

          final users =
              snapshot.data?.docs.where((doc) {
                final userData = doc.data() as Map<String, dynamic>;
                return userData['uid'] != currentUserId;
              }).toList() ??
              [];

          if (users.isEmpty) {
            return Center(child: Text('No other users found', style: TextStyle(fontSize: 16.sp)));
          }

          return ListView.builder(
            shrinkWrap: true,
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userId = users[index].id;
              final userData = users[index].data() as Map<String, dynamic>;
              final userName = userData['name'];
              final userEmail = userData['email'];

              return ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => chatsPage(
                        recevierName: userName,
                        recevierId: userId,
                      ),
                    ),
                  );
                },
                leading: CircleAvatar(child: Icon(Icons.person, size: 30.r)),
                title: Text(
                  userName,
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(userEmail, style: TextStyle(fontSize: 14.sp)),
              );
            },
          );
        },
      ),
    );
  }
}
