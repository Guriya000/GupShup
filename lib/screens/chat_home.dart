import 'package:chat/screens/chat_page.dart';
import 'package:chat/screens/login_screen.dart';
import 'package:chat/screens/registered_user.dart';

import 'package:chat/services/database.dart';
import 'package:chat/services/shared_pref.dart';
import 'package:chat/widgets/app_name.dart';
import 'package:chat/widgets/chatroomlisttile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';

class ChatHome extends StatefulWidget {
  const ChatHome({super.key});

  @override
  State<ChatHome> createState() => _ChatHomeState();
}

class _ChatHomeState extends State<ChatHome> {
  TextEditingController searchcontroller = TextEditingController();
  bool search = false;

  String? myName, myProfilePic, myUsername, myEmail;

  getthesharedpref() async {
    try {
      myUsername = await SharedPreferenceHelper().getUserName();
      print("Load Username: $myUsername");
      if (myUsername == null) {
        print("Username is null in sharedpref");
      }
    } catch (e) {
      print("Error: $e");
    }

    myName = await SharedPreferenceHelper().getDisplayName();
    myProfilePic = await SharedPreferenceHelper().getUserPhotoUrl();

    myEmail = await SharedPreferenceHelper().getUserEmail();
    setState(() {});
  }

  ontheload() async {
    await getthesharedpref();
    chatRoomStream = await DatabaseMethod().getChatRooms(myUsername!);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    initializeChatRooms();
    ontheload();
  }

  String getChatRoomIdbyUsername(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  var queryResultSet = [];
  var tempSearchStore = [];

  void initiateSearch(String value) async {
    if (value.isEmpty) {
      setState(() {
        queryResultSet = [];
        tempSearchStore = [];
        search = false;
      });
      return;
    }

    setState(() {
      search = true;
    });

    String capitalizedValue = value[0].toUpperCase() + value.substring(1);

    if (queryResultSet.isEmpty && value.length == 1) {
      // Fetch from database
      try {
        QuerySnapshot docs = await DatabaseMethod().Search(value);
        List<Map<String, dynamic>> results = docs.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
        setState(() {
          queryResultSet = results;
          tempSearchStore = results.where((element) {
            return element["username"].toString().toLowerCase().startsWith(
              value.toLowerCase(),
            );
          }).toList();
        });
      } catch (e) {
        print("Search error: $e");
      }
    } else {
      // Filter already fetched results
      setState(() {
        tempSearchStore = queryResultSet.where((element) {
          return element["username"].toString().startsWith(capitalizedValue);
        }).toList();
      });
    }
  }

  Stream<QuerySnapshot>? chatRoomStream;

  Future<void> initializeChatRooms() async {
    await getthesharedpref(); // Ensure this completes first
    print("My username: $myUsername"); // Verify username

    final stream = await DatabaseMethod().getChatRooms(myUsername!);
    setState(() {
      chatRoomStream = stream;
    });
  }

  Widget chatRoomList() {
    if (chatRoomStream == null) {
      return Center(child: CircularProgressIndicator());
    }

    return StreamBuilder<QuerySnapshot>(
      stream: chatRoomStream,
      builder: (context, AsyncSnapshot snapshot) {
        // Debug prints
        print("Stream state: ${snapshot.connectionState}");
        if (snapshot.hasError) print("Error: ${snapshot.error}");
        if (snapshot.hasData)
          print("Data count: ${snapshot.data!.docs.length}");

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No chat rooms found"));
        }

        return ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot ds = snapshot.data!.docs[index];
            // final ds = snapshot.data!.docs[index];
            print("Chat room ${ds.id}"); // Debug print

            return Chatroomlisttile(
              lastMessage: ds['lastMessage'] ?? '',
              chatRoomId: ds.id,
              myUsername: myUsername!,
              time: ds['lastmesssageSendts']?.toString() ?? '',
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 10,
                right: 10,
                top: 37,
                bottom: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  search
                      ? Expanded(
                          child: TextField(
                            controller: searchcontroller,
                            onChanged: (value) {
                              initiateSearch(value);
                            },
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Search User",
                              hintStyle: GoogleFonts.oxanium(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        )
                      : AppName(),
                  search
                      ? GestureDetector(
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                search = false;
                              });
                            },
                            icon: Icon(
                              Icons.close,
                              size: 30,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        )
                      : IconButton(
                          icon: Icon(
                            Icons.search,
                            size: 30,
                            color: Theme.of(context).primaryColor,
                          ),
                          onPressed: () {
                            setState(() {
                              search = true;
                              queryResultSet = [];
                              tempSearchStore = [];
                              searchcontroller.clear();
                            });
                          },
                        ),
                ],
              ),
            ),
            Container(
              height: search
                  ? MediaQuery.of(context).size.height / 1.11
                  : MediaQuery.of(context).size.height / 1.11,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: Column(
                  children: [
                    search
                        ? tempSearchStore.isEmpty
                              ? Padding(
                                  padding: EdgeInsetsGeometry.only(
                                    top: 300,

                                    right: 20,
                                    left: 20,
                                  ),
                                  child: Center(
                                    child: Text(
                                      "No record found!",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).primaryColor,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                )
                              : ListView(
                                  padding: EdgeInsets.only(left: 10, right: 10),
                                  primary: false,
                                  shrinkWrap: true,
                                  children: tempSearchStore.map((element) {
                                    return buildResultCard(element);
                                  }).toList(),
                                )
                        : Expanded(child: chatRoomList()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: search
          ? null
          : StylishBottomBar(
              onTap: (value) {
                switch (value) {
                  case 0:
                    // Navigate to Chat Page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ChatHome()),
                    );
                    break;
                  case 1:
                    // Navigate to Users Page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RegisteredUserScreen(),
                      ),
                    );
                    break;
                  case 2:
                    logoutUser(context);
                    break;
                }
              },
              backgroundColor: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              items: [
                BottomBarItem(
                  icon: Icon(CupertinoIcons.chat_bubble, color: Colors.white),
                  title: const Text(
                    'Chat',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                BottomBarItem(
                  icon: Icon(
                    Icons.supervised_user_circle_sharp,
                    color: Colors.white,
                  ),
                  title: const Text(
                    'Users',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                BottomBarItem(
                  icon: Icon(Icons.logout, color: Colors.white),
                  title: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
              option: AnimatedBarOptions(
                iconSize: 20,
                iconStyle: IconStyle.Default,
                opacity: 0.3,
              ),
            ),
    );
  }

  Widget buildResultCard(data) {
    return GestureDetector(
      onTap: () async {
        setState(() => search = false);

        // 1. Ensure myUsername is loaded
        if (myUsername == null) {
          await getthesharedpref();
          if (myUsername == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Your username is not set!")),
            );
            return;
          }
        }

        // 2. Validate clicked user's data
        if (data["username"] == null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Invalid user data")));
          return;
        }

        try {
          // 3. Generate chatRoomId
          final chatRoomId = getChatRoomIdbyUsername(
            myUsername!,
            data["username"],
          );
          print("ChatRoom ID: $chatRoomId");

          // 4. Create chat room (or skip if it exists)
          await DatabaseMethod().createChatRoom(chatRoomId, {
            'users': [myUsername, data["username"]],
            'createdAt': FieldValue.serverTimestamp(),
          });

          // 5. Navigate to ChatPage
          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                name: data["name"] ?? "No Name",
                profileurl: data["photoUrl"] ?? "",
                username: data["username"]!,
              ),
            ),
          );
        } catch (e) {
          print("Error: $e");
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Failed to start chat")));
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        child: Material(
          elevation: 5,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image.network(data["photoUrl"], height: 50, width: 50),
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data["name"],
                      style: GoogleFonts.oxanium(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    Text(
                      data["username"],
                      style: GoogleFonts.oxanium(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> logoutUser(BuildContext context) async {
  try {
    // Clear shared preferences
    await SharedPreferenceHelper().clearSharedPreferences();

    // Navigate to login screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  } catch (e) {
    print("Logout error: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).primaryColor,
        content: Text(
          "Failed to log out",
          style: GoogleFonts.oxanium(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
