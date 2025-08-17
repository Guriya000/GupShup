import 'package:chat/screens/chat_home.dart';
import 'package:chat/services/database.dart';
import 'package:chat/services/shared_pref.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:random_string/random_string.dart';

class ChatPage extends StatefulWidget {
  final String name, profileurl, username;

  const ChatPage({
    super.key,
    required this.name,
    required this.profileurl,
    required this.username,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController messagefieldcontroller = TextEditingController();

  String? myUsername, myProfilePic, myName, myEmail, messageId, chatRoomId;
  getthesharedpref() async {
    myUsername = await SharedPreferenceHelper().getUserName();
    myProfilePic = await SharedPreferenceHelper().getUserPhotoUrl();
    myEmail = await SharedPreferenceHelper().getUserEmail();
    myName = await SharedPreferenceHelper().getDisplayName();
    chatRoomId = getChatRoomIdbyUsername(myUsername!, widget.username);

    setState(() {});
  }

  ontheload() async {
    await getthesharedpref();
    await getandSetmessages();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    ontheload();
    // chatRoomId = getChatRoomIdbyUsername(myUsername!, widget.username);
  }

  getChatRoomIdbyUsername(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  Widget chatMessageTile(String message, bool sendbyme) {
    return Row(
      mainAxisAlignment: sendbyme
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                bottomRight: sendbyme
                    ? Radius.circular(0)
                    : Radius.circular(25),
                topRight: Radius.circular(25),
                bottomLeft: sendbyme ? Radius.circular(25) : Radius.circular(0),
              ),
              color: sendbyme
                  ? const Color.fromARGB(255, 210, 241, 250)
                  : Colors.pink.shade100,
            ),
            child: Text(
              message,
              style: GoogleFonts.oxanium(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  getandSetmessages() async {
    messageStream = await DatabaseMethod().getmessages(chatRoomId!);
    setState(() {});
  }

  Stream? messageStream;
  Widget chatMessage() {
    return StreamBuilder(
      stream: messageStream,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          print("Message stream data: ${snapshot.data!.docs.length}");
          snapshot.data!.docs.forEach(
            (doc) => print(doc.data()),
          ); // Print all messages

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            reverse: true,
            itemBuilder: (context, index) {
              DocumentSnapshot ds = snapshot.data!.docs[index];
              return chatMessageTile(ds['message'], ds['sendby'] == myUsername);
            },
          );
        }
        if (snapshot.hasError) {
          print("Error: ${snapshot.error}");
        }
        return Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).primaryColor,
          ),
        );
      },
    );
  }

  String formattedDate = DateFormat('h:mm a').format(DateTime.now());

  addmessage(bool sendClicked) {
    print("ChatRoom ID: $chatRoomId");
    if (chatRoomId == null) {
      print("ChatRoom ID is null");
      return;
    }

    if (messagefieldcontroller.text != "") {
      String message = messagefieldcontroller.text;

      messagefieldcontroller.text = "";
      Map<String, dynamic> messageInfoMap = {
        'message': message,
        'sendby': myUsername,
        'ts': formattedDate,
        'time': FieldValue.serverTimestamp(),
        'imgUrl': myProfilePic,
      };
      messageId ??= randomAlphaNumeric(10);
      DatabaseMethod().addMessage(messageId!, chatRoomId!, messageInfoMap).then(
        (value) {
          Map<String, dynamic> lastmessageInfoMap = {
            'lastMessage': message,
            'lastMessageSendby': myUsername,
            'lastmesssageSendts': formattedDate,
            'time': FieldValue.serverTimestamp(),
          };
          DatabaseMethod().updateLastMessageSend(
            chatRoomId!,

            lastmessageInfoMap,
          );
          if (sendClicked) {
            messageId = null;
          }
          getandSetmessages();
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 20),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ChatHome()),
            );
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: Image.network(widget.profileurl, height: 30, width: 30),
            ),
            SizedBox(width: 10),
            Text(
              widget.name,
              style: GoogleFonts.oxanium(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),

      body: Stack(
        children: [
          // Chat message input
          Container(
            margin: EdgeInsets.only(bottom: 10),
            height: MediaQuery.of(context).size.height * 0.78,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(color: Colors.white),
            child: chatMessage(),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              alignment: Alignment.bottomCenter,
              child: Material(
                elevation: 5,
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: TextField(
                            controller: messagefieldcontroller,
                            decoration: InputDecoration(
                              hintText: 'Type a message',
                              hintStyle: GoogleFonts.oxanium(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                              border: InputBorder.none,

                              contentPadding: EdgeInsets.all(8),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.send, color: Colors.white),
                            onPressed: () {
                              print("ChatRoom ID: $chatRoomId");
                              addmessage(true);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
