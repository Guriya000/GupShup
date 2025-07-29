import 'package:chat/screens/chat_page.dart';
import 'package:chat/services/database.dart';
import 'package:chat/widgets/app_name.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatHome extends StatefulWidget {
  const ChatHome({super.key});

  @override
  State<ChatHome> createState() => _ChatHomeState();
}

class _ChatHomeState extends State<ChatHome> {
  TextEditingController searchcontroller = TextEditingController();
  bool search = false;
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

  // initiateSearch(String value) async {
  //   // Clear results if search is empty
  //   if (value.isEmpty) {
  //     setState(() {
  //       queryresultset = [];
  //       tempsearchstore = [];
  //     });
  //     return;
  //   }

  //   setState(() {
  //     search = true;
  //   });

  //   // Capitalize first letter (fixed method name)
  //   var capitalizedValue =
  //       value.substring(0, 1).toUpperCase() + value.substring(1);

  //   if (queryresultset.isEmpty && value.length == 1) {
  //     try {
  //       // Fixed syntax for then() and added await
  //       QuerySnapshot docs = await DatabaseMethod().Search(value);
  //       // Fixed for loop syntax
  //       setState(() {
  //         queryresultset = docs.docs.map((doc) => doc.data()).toList();
  //       });
  //     } catch (e) {
  //       print("Search error: $e");
  //     }
  //   } else {
  //     // Fixed forEach syntax and filtering
  //     setState(() {
  //       tempsearchstore = queryresultset.where((element) {
  //         return element["username"].toString().startsWith(capitalizedValue);
  //       }).toList();
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
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
                                color: Colors.white60,
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
                              color: Colors.white,
                            ),
                          ),
                        )
                      : IconButton(
                          icon: Icon(
                            Icons.search,
                            size: 30,
                            color: Colors.white,
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
                  ? MediaQuery.of(context).size.height / 1.10
                  : MediaQuery.of(context).size.height / 1.13,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
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
                        : Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatPage(),
                                    ),
                                  );
                                },
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          100,
                                        ),
                                        child: Image.asset(
                                          'assets/krishna.jpg',
                                          fit: BoxFit.cover,
                                          height: 50,
                                          width: 50,
                                        ),
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Krishna",
                                          style: GoogleFonts.oxanium(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          "Hello, how are you?",
                                          style: GoogleFonts.oxanium(
                                            fontSize: 16,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      width:
                                          MediaQuery.of(context).size.width / 5,
                                    ),
                                    Text(
                                      "4:30 PM",
                                      textAlign: TextAlign.end,
                                      style: GoogleFonts.oxanium(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Divider(
                                color: Colors.grey.shade300,
                                thickness: 1,
                              ),
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(100),
                                      child: Image.asset(
                                        'assets/krishna.jpg',
                                        fit: BoxFit.cover,
                                        height: 50,
                                        width: 50,
                                      ),
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Krishna",
                                        style: GoogleFonts.oxanium(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        "Hello, how are you?",
                                        style: GoogleFonts.oxanium(
                                          fontSize: 16,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width / 5,
                                  ),
                                  Text(
                                    "4:30 PM",
                                    textAlign: TextAlign.end,
                                    style: GoogleFonts.oxanium(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildResultCard(data) {
    return GestureDetector(
      onTap: () {
        setState(() {
          search = false;
        });
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
                SizedBox(width: 8),
                ClipRRect(
                  borderRadius: BorderRadiusGeometry.circular(100),

                  child: Image.network(data["photoUrl"], height: 50, width: 50),
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data["name"],
                      style: GoogleFonts.oxanium(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      data["username"],
                      style: GoogleFonts.oxanium(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Colors.grey,
                      ),
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
