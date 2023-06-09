import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'model.dart';

class UserMatch extends Equatable{
  final String? id;
  final String userId;
  final User matchedUser;
  final String chat;

  const UserMatch({ this.id, required this.userId, required this.matchedUser, required this.chat});
  
  @override
  // TODO: implement props
  List<Object?> get props => [id,userId,matchedUser,chat];

  static UserMatch fromSnapshoot(DocumentSnapshot snap){
    return UserMatch(
      id: snap.id, 
      userId: snap['userId'],
      matchedUser: User(id: snap.id, name: snap['matchedUser']['name'], age: snap['matchedUser']['age'], gender: snap['matchedUser']['gender'], imageUrls: snap['matchedUser']['imageUrls'], interests: snap['matchedUser']['interests']),
      // User.fromSnapshoot(snap['matchedUser']), 
      chat: snap['chat'],
      );
  }

  Map<String, dynamic> toMap(){
    return {
      'id' : id,
      'userId': userId,
      'matchedUser': matchedUser.toMap(),
      'chat': chat,
    };

  }





// static List<UserMatch> matches = [
//     UserMatch(
//       id: 1,
//       userId: 1,
//       matchedUser: User.users[1],
//       chat: Chat.chats
//           .where((chat) => chat.userId == 1 && chat.matchedUserId == 2)
//           .toList(),
//     ),
//     UserMatch(
//       id: 2,
//       userId: 1,
//       matchedUser: User.users[2],
//       chat: Chat.chats
//           .where((chat) => chat.userId == 1 && chat.matchedUserId == 3)
//           .toList(),
//     ),
//     UserMatch(
//       id: 3,
//       userId: 1,
//       matchedUser: User.users[3],
//       chat: Chat.chats
//           .where((chat) => chat.userId == 1 && chat.matchedUserId == 4)
//           .toList(),
//     ),
//     UserMatch(
//       id: 4,
//       userId: 1,
//       matchedUser: User.users[4],
//       chat: Chat.chats
//           .where((chat) => chat.userId == 1 && chat.matchedUserId == 5)
//           .toList(),
//     ),
//     UserMatch(
//       id: 5,
//       userId: 1,
//       matchedUser: User.users[5],
//       chat: Chat.chats
//           .where((chat) => chat.userId == 1 && chat.matchedUserId == 6)
//           .toList(),
//     ),
//     UserMatch(
//       id: 6,
//       userId: 1,
//       matchedUser: User.users[6],
//       chat: Chat.chats
//           .where((chat) => chat.userId == 1 && chat.matchedUserId == 7)
//           .toList(),
//     ),
//     UserMatch(
//       id: 7,
//       userId: 1,
//       matchedUser: User.users[7],
//       chat: Chat.chats
//           .where((chat) => chat.userId == 1 && chat.matchedUserId == 8)
//           .toList(),
//     ),
//     UserMatch(
//       id: 8,
//       userId: 1,
//       matchedUser: User.users[8],
//       chat: Chat.chats
//           .where((chat) => chat.userId == 1 && chat.matchedUserId == 9)
//           .toList(),
//     ),
//   ];

  
  
 }