import 'package:chat/screens/chat_page.dart';
import 'package:chat/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Chatroomlisttile extends StatefulWidget {
  final String lastMessage;
  final String chatRoomId;
  final String myUsername;
  final String time;

  const Chatroomlisttile({
    super.key,
    required this.lastMessage,
    required this.chatRoomId,
    required this.myUsername,
    required this.time,
  });

  @override
  State<Chatroomlisttile> createState() => _ChatroomlisttileState();
}

class _ChatroomlisttileState extends State<Chatroomlisttile> {
  String profileurl = "";
  String name = "";
  String username = "";
  String id = "";
  bool isLoading = true;
  String error = "";

  Future<void> getthisuserinfo() async {
    try {
      setState(() {
        isLoading = true;
        error = ""; // Reset error on retry
      });

      // 1. Improved username extraction
      username = extractOtherUsername(widget.chatRoomId, widget.myUsername);

      print("Extracted username: $username"); // Debug log

      // 2. Case-insensitive search
      final QuerySnapshot querySnapshot = await DatabaseMethod()
          .getthisuserinfo(username.toLowerCase());

      // 3. Improved null checks
      if (querySnapshot.docs.isEmpty) {
        throw Exception("User '$username' not found in database");
      }

      final userData = querySnapshot.docs[0].data() as Map<String, dynamic>;

      setState(() {
        name = userData["name"]?.toString() ?? "Unknown";
        profileurl = userData["photoUrl"]?.toString() ?? "";
        id =
            userData["id"]?.toString() ??
            userData["Id"]?.toString() ??
            ""; // Handle both cases
      });
    } catch (e) {
      setState(() {
        error = e.toString().replaceAll("Exception: ", "");
      });
      print("Error fetching user: $e");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  // New helper method to handle different chatroom ID formats
  String extractOtherUsername(String chatRoomId, String myUsername) {
    // Handle underscore-separated format (user1_user2)
    if (chatRoomId.contains('_')) {
      final parts = chatRoomId.split('_');
      return parts[0] == myUsername ? parts[1] : parts[0];
    }
    // Handle hyphen-separated format (user1-user2)
    else if (chatRoomId.contains('-')) {
      final parts = chatRoomId.split('-');
      return parts[0] == myUsername ? parts[1] : parts[0];
    }
    // Fallback for other formats
    return chatRoomId.replaceAll(myUsername, '');
  }

  @override
  void initState() {
    super.initState();
    getthisuserinfo();
  }

  String _formatTime(String timestamp) {
    try {
      // Implement your time formatting logic here
      // Example: Convert Firestore timestamp to readable format
      return timestamp; // Placeholder - implement your formatting
    } catch (e) {
      return timestamp;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const double avatarSize = 50;
    const double horizontalPadding = 16;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: isLoading
          ? _buildLoadingState()
          : error.isNotEmpty
          ? _buildErrorState()
          : _buildChatTile(theme, avatarSize),
    );
  }

  Widget _buildLoadingState() {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey.shade200,
        radius: 25,
        child: CircularProgressIndicator(
          padding: EdgeInsets.all(12),
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).primaryColor,
          ),
        ),
      ),
      title: Text("Loading..."),
    );
  }

  Widget _buildErrorState() {
    return ListTile(
      leading: CircleAvatar(radius: 25, child: Icon(Icons.error_outline)),
      title: Text(
        error,
        style: TextStyle(color: Theme.of(context).primaryColor),
      ),
    );
  }

  void _navigateToChat(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return ChatPage(
            name: name,
            profileurl: profileurl,
            username: username,
          );
        },
      ),
    );
  }

  Widget _buildChatTile(ThemeData theme, double avatarSize) {
    return GestureDetector(
      onTap: () {
        _navigateToChat(context);
      },
      child: Card(
        color: Colors.pink.shade50,
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: avatarSize / 2,
                backgroundImage: profileurl.isNotEmpty
                    ? NetworkImage(profileurl)
                    : null,
                child: profileurl.isEmpty ? const Icon(Icons.person) : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.isNotEmpty ? name : username,
                      style: GoogleFonts.oxanium(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.lastMessage,
                      style: GoogleFonts.oxanium(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _formatTime(widget.time),
                style: GoogleFonts.oxanium(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
