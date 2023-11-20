import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_geo_hash/geohash.dart' as geohash;
import 'package:geocoding_platform_interface/src/models/placemark.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lomi/src/Blocs/SwipeBloc/swipebloc_bloc.dart';

import 'package:lomi/src/Data/Models/chat_model.dart';
import 'package:lomi/src/Data/Models/enums.dart';
import 'package:lomi/src/Data/Models/message_model.dart';
import 'package:lomi/src/Data/Models/user.dart';
import 'package:lomi/src/Data/Models/userpreference_model.dart';
import 'package:lomi/src/Data/Repository/Storage/storage_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Models/likes_model.dart';
import '../../Models/model.dart';
import '../../Models/payment_model.dart';
import 'base_database_repository.dart';

class DatabaseRepository extends BaseDatabaseRepository{
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  @override
  Stream<User> getUser(String userId, Gender users) {
    try {
      return _firebaseFirestore.collection(users.name)
      .doc(userId)
      .snapshots()
      .map((snap) => User.fromSnapshoot(snap));
      
    } on FirebaseException catch(e) {
      
      print('Failed with code ${e.code} : ${e.message}');
      throw Exception(e.message);
    } on Exception
    catch (e) {
      throw Exception(e);
    }
    
     
  }

  @override
  Future<void> updateUserPictures(User user, String downloadURL) async{
    try {
  
    //String downloadURL = await StorageRepository().getDownloadURL(user,imageName);

    return await _firebaseFirestore.collection(user.gender)
            .doc(user.id)
            .update({'imageUrls': FieldValue.arrayUnion([downloadURL])});

    } on FirebaseException catch(e){
      print(e.message);
      throw Exception(e.message);
      
    } catch(e){
      print(e);
      throw(Exception(e));
    }
  }
  
  @override
  Future<void> createUser(User user) async {
    //String documentId = 
    try{
    await _firebaseFirestore.collection(user.gender).doc(user.id).set(user.toMap());
    } on FirebaseException catch(e){
      print(e.message);
      throw(Exception(e.message));
    }catch(e){
      print(e);
      throw(Exception(e));
    }
    // .then((value) {
    //   print("User added, ID: ${value.id}");
    //   return value.id;
    //   });

     
  }
  
  @override
  Future<void> updateUser(User user) async {
    try{
    return await _firebaseFirestore.collection(user.gender).doc(user.id)
    .update(user.toMap()).then((value) {print('user updated');});

    } on FirebaseException catch(e){
      print(e.message);
      throw(Exception(e.message));
    }catch(e){
      print(e);
      throw(Exception(e));
    }
    
  }
  
  @override
  Stream<List<User>> getUsers(String userId, Gender users) {
    //  Position myLocation = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    // geohash.MyGeoHash myGeoHash = geohash.MyGeoHash();
    // String hash = myGeoHash.geoHashForLocation(geohash.GeoPoint(myLocation.latitude, myLocation.longitude));
    // _firebaseFirestore.collection(user.gender).snapshots()
    // .forEach((element) {
    //   element.docs.forEach((doc) {
    //    // updateUser(User.fromSnapshootOld(doc));
    //    _firebaseFirestore.collection(user.gender).doc(doc.id)
    //    .update({'geohash': hash });
    //   });
    // });
   // _firebaseFirestore.collection(user.gender).where('location[0]', whereIn: [99,21] ).where('location[1]', whereIn: [20,12]);
    try {
  return _firebaseFirestore.collection(users.name).snapshots()
  .map((snap) => snap.docs
  .map((doc) => User.fromSnapshoot(doc)).toList() );
}on FirebaseException catch (e){
  throw Exception(e.message);
}
 on Exception catch (e) {
  // TODO
  throw Exception(e);
}

    
  }

  Future<List<User>> getUsersWithLimit(User _user) async{
    try {
      final user = await _firebaseFirestore.collection(_user.gender).doc(_user.id).get()
      .then((doc) => User.fromSnapshoot(doc));
      final preference = await _firebaseFirestore.collection(user.gender).doc(_user.gender).collection('userpreference').doc('preference').get().then((doc) => UserPreference.fromSnapshoot(doc));

      //final findWithLocation = await _firebaseFirestore.collection(user.gender)


      return await _firebaseFirestore.collection(user.gender)
          .where('gender', isEqualTo: user.gender)
          .where('age', isLessThanOrEqualTo: preference.ageRange![1])
          .where('age', isGreaterThanOrEqualTo: preference.ageRange![0])
          .limit(10)
          .get().then(
            (value) => value.docs.map((doc) => User.fromSnapshoot(doc)).toList() ); 
    }on Exception catch (e) {
      throw Exception(e);
    }
  }
  
  @override
  Future<bool> userLike(User user, User matchUser, bool superLike) async {
    try {

    var result = await _firebaseFirestore.collection(user.gender)
    .doc(user.id)
    .collection('likes')
    .doc(matchUser.id).get();

    if(!result.exists){

    
   await _firebaseFirestore
    .collection(matchUser.gender)
    .doc(matchUser.id)
    .collection('likes')
    .doc(user.id)
    //.add(likedUser.toMap()..addAll({'userId' : likedUser.id}));
    .set(
      {
        'userId': user.id,
        'timestamp': FieldValue.serverTimestamp(),
        'superLike': superLike,
        'user': user.toMap()

      }
      
    );

 
    String viewed = await _firebaseFirestore.collection(user.gender).doc(user.id).collection('viewedProfiles').doc('viewed').get().then((value) => value['matches']);

    await _firebaseFirestore
        .collection(user.gender)
        .doc(user.id)
        .collection('viewedProfiles')
        .doc('viewed')
        .update({
          'matches': '$viewed,${matchUser.id} true'
        }
        );
        // .doc(matchUser.id)
        // .set({'liked' : true});


    return false;
    }

    if(result.exists){
      var likedMeUser = Like.fromSnapshoot(result);
      await likeLikedMeUser(user, likedMeUser, superLike);
      return true;
    //   await _firebaseFirestore
    //   .collection(user.gender)
    //   .doc(user.id)
    //   .collection('matches')
    //   .doc(matchUser.id)
    //   .set(
    //     {
    //   'timestamp' : FieldValue.serverTimestamp(),
    //   'userId': matchUser.id,
    //   'name': matchUser.name,
    //   'imageUrls': matchUser.imageUrls,
    //   'verified': matchUser.verified,
    //   'chatOpened': false,
    //   'nameSearch': searchName(matchUser.name),
    //   'superlike': superLike,
    // }
    // );
       // UserMatch(userId: userId, matchedUser: likedUser, chat:'notOpened').toMap());

      // await _firebaseFirestore
      // .collection(user.gender)
      // .doc(matchUser.id)
      // .collection('matches')
      // .doc(user.id)
      // .set(
      //   {
      //     'timestamp' : FieldValue.serverTimestamp(),
      //     'userId': matchUser.id,
      //     'name': matchUser.name,
      //     'imageUrls': matchUser.imageUrls,
      //     'verified': matchUser.verified,
      //     'chatOpened': false,
      //     'nameSearch': searchName(matchUser.name),
      //     'superlike': superLike,
      //   }
      //   );
        
      

      // await _firebaseFirestore
      //   .collection(user.gender)
      //   .doc(user.id)
      //   .collection('likes')
      //   .doc(matchUser.id)
      //   .delete();

     // return true;

      
    }
    }on FirebaseException catch(e){
      throw Exception(e.message);
    } on Exception
     catch (e) {
      print(e.toString());
    }
    return false;

    
  }
  
  @override
  Future<void> userPassed(User user, User passedUser) async {
    try {
    
   // await _firebaseFirestore.collection(user.gender).doc(userId).collection('passed').doc(passedUser.id).set(passedUser.toMap());
    String matches = await _firebaseFirestore.collection(user.gender).doc(user.id).collection('viewedProfiles').doc('viewed').get().then((value) => value['matches']);
    String newMatches = '$matches,${passedUser.id} false';
    await _firebaseFirestore
        .collection(user.gender)
        .doc(user.id)
        .collection('viewedProfiles')
        .doc('viewed')
        .update({
          'matches': newMatches
        });

        // .doc(passedUser.id)
        // .set({'liked' : false});

    // final result = await _firebaseFirestore.collection(user.gender)
    //     .doc(user.id)
    //     .collection('likes')
    //     .doc(passedUser.id)
    //     .get();

    // if(result.exists){
    //   await _firebaseFirestore.collection(user.gender)
    //         .doc(user.id)
    //         .collection('likes')
    //         .doc(passedUser.id)
    //         .delete();

    // }

    }on FirebaseException catch(e){
      print(e.message);
      throw Exception(e.message);
    }on Exception catch (e) {
      print(e.toString());
      throw Exception(e);
    }
  }
  
  @override
  Stream<List<UserMatch>> getMatches(String userId, Gender users)  {
    try {
  return _firebaseFirestore.collection(users.name)
  .doc(userId)
  .collection('matches')
  .orderBy('timestamp', descending: true)
  .snapshots()
  .map((snap) => snap.docs
  .map((match) => UserMatch.fromSnapshoot(match)).toList());
}on FirebaseException catch (e){
  print(e.message);
  throw Exception(e.message);

}
 on Exception catch (e) {
  // TODO

  throw Exception(e);
}
    
  }
  
  @override
  Stream<List<Like>> getLikedMeUsers(String userId, Gender users) {
   try {
  return _firebaseFirestore.collection(users.name)
   .doc(userId)
   .collection('likes')
   .snapshots()
   .map((snap) => 
    snap.docs
    .map((user) => Like.fromSnapshoot(user)).toList()
   );
}on FirebaseException catch (e){
  throw Exception(e.message);
}
 on Exception catch (e) {
  // TODO
  throw Exception(e);
}
  }
  
  @override
  Future<void> deleteLikedMeUser(String userId, Gender users, String likedMeUserId) async {
    try {
  await _firebaseFirestore
  .collection(users.name)
  .doc(userId)
  .collection('likes')
  .doc(likedMeUserId)
  .delete();

  String viewed = await _firebaseFirestore.collection(users.name).doc(userId).collection('viewedProfiles').doc('viewed').get().then((value) => value['matches']);

    await _firebaseFirestore
        .collection(users.name)
        .doc(userId)
        .collection('viewedProfiles')
        .doc('viewed')
        .update({
          'matches': '$viewed,$likedMeUserId true'
        });

}on FirebaseException catch (e){
  throw Exception(e.message);

} on Exception catch (e) {
  // TODO
  throw Exception(e);
}
  }
  
  @override
  Future<void> 
  likeLikedMeUser(User user, Like likedMeUser, bool isSuperLike) async {
    try {
    await _firebaseFirestore
    .collection(user.gender)
    .doc(user.id)
    .collection('matches')
    .doc(likedMeUser.user.id)
    .set({
          'timestamp' : FieldValue.serverTimestamp(),
          'userId': likedMeUser.user.id,
          'name': likedMeUser.user.name,
          'imageUrls': likedMeUser.user.imageUrls,
          'verified': likedMeUser.user.verified,
          'chatOpened': false,
          'nameSearch': searchName(likedMeUser.user.name),
          'superLike': likedMeUser.superLike?? false,
          'gender': likedMeUser.user.gender

    });

    await _firebaseFirestore
    .collection(likedMeUser.user.gender)
    .doc(likedMeUser.user.id)
    .collection('matches')
    .doc(user.id)
    .set({
          'timestamp' : FieldValue.serverTimestamp(),
          'userId': user.id,
          'name': user.name,
          'imageUrls': user.imageUrls,
          'verified': user.verified,
          'chatOpened': false,
          'nameSearch': searchName(user.name),
          'superLike': isSuperLike,
          'gender': user.gender
      
      
    });
    String viewed = await _firebaseFirestore.collection(user.gender).doc(user.id).collection('viewedProfiles').doc('viewed').get().then((value) => value['matches']);

    await _firebaseFirestore
        .collection(user.gender)
        .doc(user.id)
        .collection('viewedProfiles')
        .doc('viewed')
        .update({
          'matches': '$viewed,${likedMeUser.user.id} true'
        });

    await _firebaseFirestore.collection(user.gender)
    .doc(user.id)
    .collection('likes')
    .doc(likedMeUser.user.id)
    .delete();
      
    }on FirebaseException catch (e){
    throw Exception(e.message);
  }
    on Exception catch (e) {
      throw Exception(e);     
    }
    
  }
  
  @override
  Future<void> openChat(Message message, Gender users) async {
    try {
      //await sendMessage(message,users);
      

      await _firebaseFirestore.collection(users.name)
      .doc(message.senderId)
      .collection('matches')
      .doc(message.receiverId)
      .collection('chats')
      .doc('chat')
      .set({'timestamp': FieldValue.serverTimestamp()});
      
      //for the other user
      await _firebaseFirestore.collection(users == Gender.men ? Gender.women.name : Gender.men.name)
      .doc(message.receiverId)
      .collection('matches')
      .doc(message.senderId)
      .update({'chatOpened': true});

      await _firebaseFirestore.collection(users == Gender.men ? Gender.women.name : Gender.men.name)
      .doc(message.receiverId)
      .collection('matches')
      .doc(message.senderId)
      .collection('chats')
      .doc('chat')
      .set({'timestamp': FieldValue.serverTimestamp()});
      //.set({'timestamp': message.timestamp})
      await sendMessage(message,users);

      //adding messages collection
      // await _firebaseFirestore.collection(user.gender)
      // .doc(userId)
      // .collection('matches')
      // .doc(matchedUserId)
      // .collection('chat')
      // .doc('chat')
      // .collection('messages')
      // ;

      await _firebaseFirestore.collection(users.name)
      .doc(message.senderId)
      .collection('matches')
      .doc(message.receiverId)
      .update(
        {'chatOpened': true}
        ).then((value) {
         print('here');
        }
         );

        await _firebaseFirestore.collection(users == Gender.men ? Gender.women.name : Gender.men.name)
      .doc(message.receiverId)
      .collection('matches')
      .doc(message.senderId)
      .update({'chatOpened': true});
      
    }on FirebaseException catch (e){
    throw Exception(e.message);

  }on Exception catch (e) {
      throw Exception(e);
    }
  }
  
  @override
  Future<User> getUserbyId(String userId, String? gender) async {
    try {
  return await _firebaseFirestore
      .collection(gender??'men')
      .doc(userId)
      .get()
      .then((doc) async { 
        if(doc.exists){
          return User.fromSnapshoot(doc);
        }
        return await _firebaseFirestore.collection('women').doc(userId).get().then((value) => User.fromSnapshoot(value));

        }
        );

}on FirebaseException catch (e){
  throw Exception(e.message);
}
 on Exception catch (e) {
  // TODO
  throw Exception(e);
}
        
  }
  
  @override
  Future<Gender> isUserAlreadyRegistered(String userId) async {
   try {
  return await _firebaseFirestore
   .collection('women')
   .doc(userId)
   .get()
   .then((user)async {
     if(user.exists){
      return Gender.women;
     }
     return await  _firebaseFirestore.collection('men').doc(userId).get().then((value) => value.exists? Gender.men : Gender.nonExist);


     });

}on FirebaseException catch (e){
  throw Exception(e.message);
}
 on Exception catch (e) {
  // TODO
  throw Exception(e);
}
  }

//************************ Messages repository *******************************

  @override
  Stream<List<Message>> getChats(String userId, Gender users, String matchedUserId){
    try {
  return _firebaseFirestore.collection(users.name)
    .doc(userId)
    .collection('matches')
    .doc(matchedUserId)
    .collection('chats')
    .doc('chat')
    .collection('messages')
    .orderBy('timestamp', descending: true)
    .limit(15)
    .snapshots()
    .map((snap) => snap.docs
    .map((doc) => Message.fromSnapshoot(doc))
    .toList());
}on FirebaseException catch (e){
  throw Exception(e.message);
}
 on Exception catch (e) {
  // TODO
  throw Exception(e);
}
      
  }

  @override
  Stream<List<Message>> getLastMessage(String userId, Gender users, String matchedUserId)  {
    try {
  var result =   _firebaseFirestore
  .collection(users.name)
  .doc(userId)
  .collection('matches')
    .doc(matchedUserId)
    .collection('chats')
    .doc('chat')
    
  .collection('messages')
  .orderBy('timestamp', descending: true)
  .limit(1)
  .snapshots()
  .map((msg) => 
    msg.docs.map(
    (e) => Message.fromSnapshoot(e)).toList()
   );
  
  return result;
 

  // .then((message) async => 
  //   await _firebaseFirestore.collection('messages')
  //   .doc(message.docs.first.id).get()
  //   .then((msg) => Message.fromSnapshoot(msg))
  
  // );
}on FirebaseException catch (e){
  throw Exception(e.message);
}
 on Exception catch (e) {
  // TODO
  throw Exception(e);
}

  }
  
  @override
  Future<void> sendMessage(Message message, Gender users) async{
    try {
  var docRef =await _firebaseFirestore.collection(users.name)
      .doc(message.senderId)
      .collection('matches')
      .doc(message.receiverId)
      .collection('chats')
      .doc('chat')
      .collection('messages')
      .add(message.toMap());
  
  await _firebaseFirestore.collection(users == Gender.men ? Gender.women.name : Gender.men.name)
      .doc(message.receiverId)
      .collection('matches')
      .doc(message.senderId)
      .collection('chats')
      .doc('chat')
      .collection('messages')
      .doc(docRef.id)
      .set(message.toMap());
 
 await _firebaseFirestore.collection(users.name)
      .doc(message.senderId)
      .collection('matches')
      .doc(message.receiverId)
      .update({
        'timestamp': FieldValue.serverTimestamp()
      });
 await _firebaseFirestore.collection(users == Gender.men ? Gender.women.name : Gender.men.name)
      .doc(message.receiverId)
      .collection('matches')
      .doc(message.senderId)
      .update({
        'timestamp': FieldValue.serverTimestamp()
      });
      
      

} on FirebaseException catch (e){
  throw Exception(e.message);
}
 on Exception catch (e) {
  // TODO
  throw Exception(e);
}
    
  }

  //**************** UserPreference Repository ****************** */

  @override
  Stream<UserPreference> getUserPreference(String userId, Gender users) {
    try {
  return  _firebaseFirestore
      .collection(users.name)
      .doc(userId)
      .collection('userpreference')
      .doc('preference')
      .snapshots()
      .map((snap) => UserPreference.fromSnapshoot(snap));
}on FirebaseException catch (e){
  throw Exception(e.message);
}
 on Exception catch (e) {
  // TODO
  throw Exception(e);
}
  }
  
  @override
  Future<void> updateUserPreference(UserPreference userPreference, Gender users) async{
    try {
  await _firebaseFirestore.collection(users.name)
    .doc(userPreference.userId)
    .collection('userpreference')
    .doc('preference')
    .set(userPreference.toMap());
}on FirebaseException catch (e){
  throw Exception(e.message);
}
 on Exception catch (e) {
  // TODO
  throw Exception(e);
}

}
  
  @override
  Future<List<User>> getUsersBasedonNearBy(String userId, Gender users, int max)async {
   
    try {

  Position myLocation = await Geolocator.getCurrentPosition(desiredAccuracy:  LocationAccuracy.low);
 
  geohash.MyGeoHash myGeoHash = geohash.MyGeoHash();
  String hash = myGeoHash.geoHashForLocation(geohash.GeoPoint(myLocation.latitude, myLocation.longitude));
  
  
  geohash.GeoPoint center = geohash.GeoPoint(myLocation.latitude, myLocation.longitude);
  //var max = prefes.maximumDistance;
  double radiusInM = max * 1000;
  // preference.maximumDistance! * 1000;
  List<List<String>> bounds = myGeoHash.geohashQueryBounds(center, radiusInM);
  List<Future> futures = [];
  
  for(List<String> b in bounds){
    var q = _firebaseFirestore.collection(users == Gender.men? Gender.women.name:Gender.men.name)
              .orderBy('geohash')
              .startAt([b[0]])
              .endAt([b[1]]);
  
    futures.add(q.get());
  }

  var viewedProfiles = await _firebaseFirestore.collection(users.name)
    .doc(userId).collection('viewedProfiles').doc('viewed')
    .get().then((value) => value.data());

    //var viewedMatches = viewedProfiles?['matches'];
    var viewedMatches = viewedProfiles?['matches'].split(',');
    viewedMatches??=[];
    List<String> likedMatches =[];
    List<String> passedMatches =[];
    for(var match in viewedMatches){
      if(match.contains(' true')){
        likedMatches.add(match.replaceAll(' true', ''));

      }else{
        passedMatches.add(match.replaceAll(' false', ''));

      }

    }
    viewedMatches = [...likedMatches,...passedMatches];
  
  
  
  var result = await Future.wait(futures).then((snapshots){
    List<User> matchingUsers = [];
    List<User> outSideRad = [];
    for(var snap in snapshots){
      if(snap.docs.length != 0){
        
      
      for(var  doc in snap.docs){
        var userLoc = geohash.GeoPoint(doc['location'].latitude, doc['location'].longitude);
        
        final distanceInKM = myGeoHash.distanceBetween(center, userLoc );
        final distanceInM = distanceInKM * 1000;
        if(distanceInM <= radiusInM){
          matchingUsers.add(User.fromSnapshoot(doc));

        }else{
          outSideRad.add(User.fromSnapshoot(doc));
        }

        
      }
      }
    }
    // if(matchingUsers.length <10){
    //   matchingUsers.addAll(outSideRad.sublist(0,10 - matchingUsers.length));
    //   //return matchingUsers;
    // }
    if(matchingUsers.isEmpty){
      //outSideRad.removeWhere((user) => likedMatches.contains(user.id));
      return outSideRad;
    }
    //matchingUsers.removeWhere((user) => likedMatches.contains(user.id));
    
    return matchingUsers;
  });
  return result;
} on Exception catch (e) {
  // TODO
  throw Exception(e);
}

   

    
  }
  
  @override
  Future<void> addVerifyMeUser(User user, bool onlyVerifyMe, String url) async {
    // TODO: implement addVerifyMeUser
    try{
      await _firebaseFirestore.collection('verify')
        .doc(user.id)
        .set({
          'userId':user.id,
          'gender': user.gender,
          'timestamp': DateTime.now(),
          'onlyVerifyMe': onlyVerifyMe,
          'url': url,
        });

      
    }on Exception catch(e){
      throw Exception(e);
    }
  }
  
//   @override
// Stream<List<User>> getNearByUsers(String userId, Position locationData)  {
//     final Geoflutterfire geo = Geoflutterfire();
    


//     final center = geo.point(latitude: locationData.latitude!, longitude: locationData.longitude!);

//     final collectionReference = _firebaseFirestore.collection(user.gender);

//    return geo.collection(collectionRef: collectionReference)
//                 .within(center: center, radius: 5, field: 'location')
//                 .map((snap) => snap.map(
//                   (doc) => User.fromSnapshoot(doc)
//                   ).toList());
//   }
  
  @override
  Future<List<User>> getUsersBasedonLOmiLogic(String userId, Gender users) {
    
    final preference = _firebaseFirestore.collection(users.name).doc(userId);
    // TODO: implement getUsersBasedonLOmiLogic
    throw UnimplementedError();
  }
  
  @override
  Future<List<User>> getUsersMainLogic(String userId, Gender gender, UserPreference preference) async {
    // TODO: implement getUsersMainLogic
    try {
      List<User> princessOrgents =[];
      
    var collectionRef = _firebaseFirestore.collection(gender == Gender.men? Gender.women.name: Gender.men.name);
    List<int> randomsForQueens = [];
    List<int> randomsForPrincess = [];
    var viewedQueens = [];
    var viewedPrincess =[];
    var viewedProfiles = await _firebaseFirestore.collection(gender.name)
    .doc(userId).collection('viewedProfiles').doc('viewed')
    .get().then((value) => value.data());

    viewedQueens = viewedProfiles?[gender == Gender.men? 'queens': 'kings'].split(',').map(int.parse).toList();
    viewedPrincess = viewedProfiles?[gender == Gender.men?'princess':'gents'].split(',');
    if(viewedProfiles?[gender == Gender.men?'princess':'gents'] != ''){
      viewedPrincess = viewedProfiles?[gender == Gender.men?'princess':'gents'].split(',').map(int.parse).toList();
    }
    List<String> viewedMatches = viewedProfiles?['matches'].split(',');
    List<String> likedMatches =[];
    List<String> passedMatches =[];
    for(var match in viewedMatches){
      if(match.contains(' true')){
        likedMatches.add(match.replaceAll(' true', ''));

      }else{
        passedMatches.add(match.replaceAll(' false', ''));

      }

    }
    viewedMatches = [...likedMatches,...passedMatches];
   

    final int queenCount =await _firebaseFirestore.collection(gender == Gender.men? 'queens' : 'kings').count().get().then((value) => value.count);
    final int princessCount = await collectionRef.where('adminchoice', isEqualTo: gender == Gender.men? 'princess':'gents' ).count().get().then((value) => value.count);
    final noOfUsers = await _firebaseFirestore.collection(gender == Gender.men? Gender.women.name:Gender.men.name).count().get().then((value) => value.count, onError: (e)=>print('error counting'));


    //get queens or kings based on gender
    for(int i=1; i<=10; i++){
      var random = Random().nextInt(queenCount);
       int howmany =0;
      while(viewedQueens.contains(random)){
        random = Random().nextInt(queenCount)+1;
        if(howmany>100){
          howmany = 0;
          break;
        }

      }
      randomsForQueens.add(random);
    }

    // List<User> queensOrKings = await _firebaseFirestore
    //     .collection(gender == Gender.men? 'queens' : 'kings')
    //     .where(gender == Gender.men? 'queenNumber' : 'kingNumber', whereIn: randomsForQueens)
    //     .get().then(
    //       (snap) => snap.docs.map((doc) => User.fromSnapshoot(doc)).toList());

    List<User> queensOrKings = await collectionRef
          .where('adminChoice', isEqualTo: gender == Gender.men?'queen':'king' )
          .where(gender == Gender.men? 'queenNumber' : 'kingNumber', whereIn: randomsForQueens)
          .get().then(
           (snap) => snap.docs.map((doc) => User.fromSnapshoot(doc)).toList());
    
    queensOrKings.removeWhere((user) => likedMatches.contains(user.id));
    // List<User> queensOrkings = await _firebaseFirestore

if(princessCount !=0){

    for(int i=1; i<=10; i++){
      var random = Random().nextInt(princessCount);
      int howmany = 0;
      while(viewedPrincess.contains(random)){
        random = Random().nextInt(princessCount)+1;
        if(howmany > 150){
          howmany = 0;
          break;
        }
      }
      randomsForPrincess.add(random);
    }
    
    princessOrgents = await collectionRef
        .where('adminchoice', isEqualTo: gender == Gender.women? 'princess' : 'gents')
        .where(gender == Gender.women ? 'princessNumber' : 'gentsNumber', whereIn: randomsForPrincess)
        .get().then(
          (snap) => snap.docs.map((doc) => User.fromSnapshoot(doc)).toList());
    
      princessOrgents.removeWhere((user) => likedMatches.contains(user.id));

    }
//end if princess count is greater than 0

    // List<User> princessOrgents = await _firebaseFirestore.collection(user.gender)
    var randForscore = Random().nextInt(noOfUsers);
    List<User> scoreUsers = await collectionRef
                              .where('rate', whereIn: [7,8,6])
                              .where('random', isGreaterThanOrEqualTo: randForscore)
                              .limit(10)
                              .get().then((snap) => snap.docs.map((doc) => User.fromSnapshoot(doc)).toList());

    scoreUsers.removeWhere((user) => queensOrKings.contains(user) );
    scoreUsers.removeWhere((user) => princessOrgents.contains(user) );

    List<User> result = [...queensOrKings, ...princessOrgents,...scoreUsers];
    if(result.length <10){
       scoreUsers = await collectionRef
                              .where('rate', whereIn: [7,8,6])
                              .where('random', isLessThan: randForscore)
                              .limit(10)
                              .get().then((snap) => snap.docs.map((doc) => User.fromSnapshoot(doc)).toList());

    scoreUsers.removeWhere((user) => queensOrKings.contains(user) );
    scoreUsers.removeWhere((user) => princessOrgents.contains(user) );

    }
    result.addAll(scoreUsers);
    //final noOfUsers = await _firebaseFirestore.collection(gender == Gender.men? Gender.women.name:Gender.men.name).count().get().then((value) => value.count, onError: (e)=>print('error counting'));
    List<User> filler =[];
    if(result.length <= 10){

    
    List<int> randoms = [];
    for(int i=0; i< 10; i++){
      randoms.add(Random().nextInt(noOfUsers)); 
    }

    List<User> filler = await _firebaseFirestore
      .collection(gender == Gender.men? Gender.women.name:Gender.men.name)
      //.where('gender', isEqualTo: gender.name)
      .where('number', whereIn: randoms)
      .get().then(
        (value) => value.docs.map(
          (doc) => User.fromSnapshoot(doc)).toList()
      );

      filler.removeWhere((user) => viewedMatches.contains(user.id));
      filler.removeWhere((element) => result.contains(element));


      result.addAll(filler);
    }

    // List<User> filler = await _firebaseFirestore
    //   .collection(user.gender)
    //   .where('gender', isEqualTo: user.gender)
    //   .where('score', isGreaterThanOrEqualTo: 1)
    //   .limit(5)
    //   .get()
    //   .then(
    //     (querySnap) => 
    //     querySnap.docs.map((doc) => 
    //     User.fromSnapshoot(doc)).toList()
    //     );
    //List<User> result = [...queensOrKings, ...princessOrgents,...filler];

    if(result.length>10){
      return result.sublist(0,10);
    }

     return result;

     } catch (e) {
      print(e);
      throw(Exception('dailyMatch'));
      
    }
  }
  


List<String> searchName(String name){
  List<String> result = [];
  String temp = '';
  for(int i = 0; i < name.length; i++){
    temp += name[i];
    result.add(temp);
  }
  return result;
}

Future<void> createDemoUsers(List<User> users) async{
  users.forEach((user) async { 
    await _firebaseFirestore.collection(user.gender).doc().set(user.toMap());
  });
}

  Future<bool> completeOnboarding({required Placemark placeMark, required User user, required bool isMocked})async {
    try {
      
    // if(isMocked){
    //  await _firebaseFirestore.collection(user.gender)
    //   .doc(user.id)
    //   .delete();
    //   return false;
    // }else{
      //creates the user

      await _firebaseFirestore.collection(user.gender)
          .doc(user.id)
          .set(user.toMap());
      
      int number =await _firebaseFirestore.collection(user.gender).count().get().then((value) => value.count);

      await _firebaseFirestore.collection(user.gender)
      .doc(user.id)
      .collection('payment')
      .doc('subscription')
      .set(
        Payment(
          country: placeMark.country ?? '', 
          countryCode: placeMark.isoCountryCode ?? '', 
          placeMark: placeMark.toJson(), 
          expireDate: 0, 
          paymentType: '', 
          paymentDetails: {}).toMap()
      );
      //add default user preference
      await _firebaseFirestore.collection(user.gender)
      .doc(user.id)
      .collection('userpreference')
      .doc('preference')
      .set(UserPreference(userId: user.id, phoneNumber: user.phoneNumber).toMap());

      await _firebaseFirestore.collection(user.gender)
        .doc(user.id)
        .collection('viewedProfiles')
        .doc('viewed')
        .set({
          'matches':'ulend',
          user.gender ==Gender.women.name?'kings':'queens':'0',
          user.gender ==Gender.women.name?'gents':'princess':'0',
        });
      //online status
      await _firebaseFirestore.collection(user.gender)
        .doc(user.id)
        .collection('online')
        .doc('status')
        .set({
          'online': true,
          'lastseen': FieldValue.serverTimestamp(),
        }
        );

      //mark  iscompleted to true in the user doc
     await _firebaseFirestore.collection(user.gender)
      .doc(user.id)
      .update({
        'isCompleted': true,
        'number': number,
        'random': Random().nextInt(10000000),
        'rate':0,
        'score':0,
        'adminChoice':'nan'
      });

      return true;

    //}

    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<Payment> getUserPayment({required userId, required Gender users}) async {
    try {
      
    return await _firebaseFirestore.collection(users.name)
            .doc(userId)
            .collection('payment')
            .doc('subscription')
            .get()
            .then(
             
              (snap) => Payment.fromSnapshoot(snap));

    } catch (e) {
      throw Exception(e.toString());
    }
  }

  void updatePayment({required String userId, required Gender users, required Map purchaseData, required int subscribtionStatus,required String paymentType, required int expireDate}) async {
    await _firebaseFirestore.collection(users.name)
          .doc(userId)
          .collection('payment')
          .doc('subscription')
          .update({
            'paymentDetails': purchaseData,
            'expireDate': expireDate,
            'subscriptionType': paymentType,
            'subscribtionStatus': subscribtionStatus
          });
  }

  Future<List<Message>> getMoreChats({required String userId, required Gender users, required String matchedUserId, required Timestamp startAfter}) async {
     
    try{
    return await _firebaseFirestore.collection(users.name)
      .doc(userId)
      .collection('matches')
      .doc(matchedUserId)
      .collection('chats')
      .doc('chat')
      .collection('messages')
      .orderBy('timestamp', descending: true)
      .startAfter([startAfter])
      .limit(5)
      .get().then(
        (snap) => snap.docs.map((doc) => 
        Message.fromSnapshoot(doc)).toList(),

        onError: (e) => print('error getting messages: ${e}')
        );
    }catch(e){
        throw Exception(e);
    }
    

  }

  Future<bool> isCompleted(Gender gender, String uid)async {
    return await _firebaseFirestore.collection(gender.name)
      .doc(uid)
      .get()
      .then((value) => value['isCompleted']);

  }

  Future<List<User>> getUsersWithAge(String userId, Gender gender) async{
    var prefes = await _firebaseFirestore.collection(gender.name).doc(userId).collection('userpreference').doc('preference').get().then((value) => UserPreference.fromSnapshoot(value));
    var userList = await _firebaseFirestore.collection(gender == Gender.men?Gender.women.name:gender.name)
          .orderBy('age')
          .where('age', isGreaterThanOrEqualTo: prefes.ageRange![0])
          .where('age', isLessThanOrEqualTo: prefes.ageRange![1])
          .limit(10)
          .get().then((value) => 
                                  value.docs.map((doc) => User.fromSnapshoot(doc)).toList() );

    return userList;
    
  }

 Future<void> deletePhoto({required String imageUrl, required String userId, required Gender users})async {
    try{

    await _firebaseFirestore.collection(users.name).doc(userId).update({'imageUrls': FieldValue.arrayRemove([imageUrl])});

    }catch(e){
      throw Exception(e);
    }
  }

  Future<List<User>> getUsersBasedonPreference(String userId, Gender gender, UserPreference prefes, User my )async {
 
      
    CollectionReference collectionReference =  _firebaseFirestore.collection(gender == Gender.women? Gender.men.name:Gender.women.name);

    // List<String> viewedProfiles = await _firebaseFirestore.collection(gender.name)
    // .doc(userId).collection('viewedProfiles')
    // .get().then((snap) => snap.docs.map((e) => e.id,).toList() );
    var viewedProfiles = await _firebaseFirestore.collection(gender.name)
    .doc(userId).collection('viewedProfiles').doc('viewed')
    .get().then((value) => value.data());

    //var viewedMatches = viewedProfiles?['matches'];
    List<String> viewedMatches = viewedProfiles?['matches'].split(',');
    List<String> likedMatches =[];
    List<String> passedMatches =[];
    for(var match in viewedMatches){
      if(match.contains(' true')){
        likedMatches.add(match.replaceAll(' true', ''));

      }else{
        passedMatches.add(match.replaceAll(' false', ''));

      }

    }
    viewedMatches = [...likedMatches,...passedMatches];


    int count = await collectionReference.count().get().then((value) => value.count);
    int random = Random().nextInt(count);

    List<int> ageWhereIn = [];

    if(prefes.ageRange![1]-prefes.ageRange![0]<=10 ){
      for(int i = prefes.ageRange![0]; i<=prefes.ageRange![1]; i++){
        ageWhereIn.add(i);
      }

    }else{
      for(int i = prefes.ageRange![0]; i<=prefes.ageRange![0]+10; i++){
        ageWhereIn.add(i);
      }

    }

    Query query = collectionReference
      .where('age', whereIn: ageWhereIn );
    
    // if(prefes.onlyShowInThisRange == false){
    //   query = collectionReference
    //         .where('age', isLessThanOrEqualTo: prefes.ageRange![1]+2);
    // }

    // List<User> users = await collectionReference.get().then((value) => 
    //   value.docs.map((doc) => User.fromSnapshoot(doc)).toList()
    //   );
     // users.removeWhere((user) => viewedProfiles.contains(user.id));
    //only show me from my city
    if(prefes.onlyShowFromMyCity != null && prefes.onlyShowFromMyCity!){
      query = query.where('city', isEqualTo: my.city );
    }
    // if(prefes.onlyShowOnlineMatches !=null && prefes.onlyShowOnlineMatches!){
    //   query = query.where('online', isEqualTo: true );
    // }
    
    //alogrithm to get user which match both looking for and interests same as the user 
    //change to only looking for if they want christian they will get christian;
    List<User> users = await query
      .where('lookingFor', isEqualTo: my.lookingFor)
      //.where('interests', arrayContainsAny: my.interests )
      .where('number', isLessThanOrEqualTo: random)
      .limit(50)
      .get().then((value) => 
      value.docs.map((doc) => User.fromSnapshoot(doc)).toList()
      );
    
    users.removeWhere((user) => viewedMatches.contains(user.id));
    
    if(users.length <10){
      random = Random().nextInt(count);
      List<User> users2 = await query
      .where('lookingFor', isEqualTo: my.lookingFor)
      
      .where('number', isGreaterThan: random)
      .limit(30)
      .get().then((value) => 
      value.docs.map((doc) => User.fromSnapshoot(doc)).toList()
      );
      
      users.addAll(users2);
    }
    users.removeWhere((user) => viewedMatches.contains(user.id));

 


  List<User> ageFiltered = [];
  List<User>ageFilteredFiller=[];

  for(var user in users) {
    if(user.age >= prefes.ageRange![0] && user.age <= prefes.ageRange![1]){
      ageFiltered.add(user);
    }
    if((user.age >= prefes.ageRange![0]-5 && user.age < prefes.ageRange![0]) || (user.age <= prefes.ageRange![1]+5 && user.age >prefes.ageRange![0]) ){
      ageFilteredFiller.add(user);

      }
    }
 
  //{user.age < my.age[0] && user.age >= my.age[1] } 

  if(ageFiltered.length < 10 ){
    ageFilteredFiller.sort((a, b) => a.age.compareTo(b.age),);

    if(ageFilteredFiller.isNotEmpty){
      ageFiltered.addAll(ageFilteredFiller);
    }
    
    if(ageFiltered.length < 10){
      return ageFiltered;
    }
    return ageFiltered.sublist(0,10);
  }

    return ageFiltered.sublist(0,10); 
   // return users;
  }

  Future<UserPreference> getPreference(String userId, Gender gender)async{
    return await _firebaseFirestore.collection(gender.name).doc(userId).collection('userpreference').doc('preference').get().then((value) => UserPreference.fromSnapshoot(value));

  }

  void updateConsumable({required String userId, required Gender users,required String field, required int value})async {
    await _firebaseFirestore.collection(users.name)
          .doc(userId)
          .collection('payment')
          .doc('subscription')
          .update({
            field: value
          });

  }

  void seenMessage({required Message message, required Gender gender})async {
    await _firebaseFirestore.collection(gender.name)
      .doc(message.receiverId)
      .collection('matches')
      .doc(message.senderId)
      .collection('chats')
      .doc('chat')
      .collection('messages')
      .doc(message.id)
      .update({
        'seen': message.seen
      });

      await _firebaseFirestore.collection(gender == Gender.women ? Gender.men.name: Gender.women.name)
      .doc(message.senderId)
      .collection('matches')
      .doc(message.receiverId)
      .collection('chats')
      .doc('chat')
      .collection('messages')
      .doc(message.id)
      .update({
        'seen': message.seen
      });
  }

  Future<List<UserMatch>> searchMatchName({required String userId, required Gender gender, required String name})async {
    try {

      return await _firebaseFirestore.collection(gender.name)
            .doc(userId)
            .collection('matches')
            .where('nameSearch',arrayContains: name)
            .get()
            .then((value) => value.docs.map((doc) => UserMatch.fromSnapshoot(doc)).toList() );
      
    }catch(e){
      throw Exception(e);
      
    }
  }

  void unMatch({required String userId, required Gender gender, required UserMatch matchUser}) async{
    try {
      _firebaseFirestore.collection(gender.name)
        .doc(userId)
        .collection('matches')
        .doc(matchUser.id)
        .delete();
      
    } catch (e) {
      
    }

  }

  Stream<List<User>> boostedUsers(Gender gender){
    return  _firebaseFirestore.collection('boosted')
            .doc(gender == Gender.men? Gender.women.name: Gender.men.name)
            .collection('boosted')
            .snapshots()
            .map((snap) => snap.docs
            .map((doc) => User.fromSnapshoot(doc)).toList());

  }

  Future<void> updateOnlinestatus({required String userId,required Gender gender ,required bool online, bool? showstatus })async{
    try {
      await _firebaseFirestore.collection(gender.name)
        .doc(userId)
        .update({
          'online': online,
          'lastseen': FieldValue.serverTimestamp()
        });
      var update ={
          'online': online,
          'lastseen': FieldValue.serverTimestamp(),
          
      };
      if(showstatus !=null){
        update['showstatus']=showstatus;
      }
      await _firebaseFirestore.collection(gender.name)
        .doc(userId)
        .collection('online')
        .doc('status')
        .update(
          update
        );
        
      
    } catch (e) {
      
    }
  }

  Stream<DocumentSnapshot<Map<String,dynamic>>> onlineStatusChanged({required String userId,required String gender }){
    return _firebaseFirestore.collection(gender)
            .doc(userId)
            .collection('online')
            .doc('status')
            .snapshots();
  }

  Future<List<User>>getOnlineUsers({required String userId, required Gender gender, int? limit=10}) async {
    try {
      // List<String> viewedIds =[];
      // var viewedProfiles = await _firebaseFirestore.collection(gender.name).doc(userId).collection('viewedProfiles').get()
      // .then((snap){
      //   viewedIds = snap.docs.map((e) => e.id).toList();
      //   return snap.docs.map((doc) => {'id': doc.id, 'liked': doc['liked'] });
      // }
      // );

      var viewedProfiles = await _firebaseFirestore.collection(gender.name)
    .doc(userId).collection('viewedProfiles').doc('viewed')
    .get().then((value) => value.data());

    List<String> viewedMatches = viewedProfiles?['matches'].split(',');
    List<String> likedMatches =[];
    List<String> passedMatches =[];
    for(var match in viewedMatches){
      if(match.contains(' true')){
        likedMatches.add(match.replaceAll(' true', ''));

      }else{
        passedMatches.add(match.replaceAll(' false', ''));

      }

    }
    viewedMatches = [...likedMatches,...passedMatches];
    int count = await _firebaseFirestore.collection(gender == Gender.men? Gender.women.name: Gender.men.name).count().get().then((value) => value.count);

    int random = Random().nextInt(count);


      List<User> users = await _firebaseFirestore.collection(gender == Gender.men? Gender.women.name: Gender.men.name)
                      .where('online', isEqualTo: true)
                      .where('number', isGreaterThanOrEqualTo: random)
                      .limit(limit!)
                      .get()
                      
                      .then((snap) => snap.docs.map((doc) => User.fromSnapshoot(doc)).toList());
      var firstUsers = users;
      users.removeWhere((user) => viewedMatches.contains(user.id));
      List<User> recentUsers =[];
      List<User> secondUsers =[];
      if(users.length < limit){
       secondUsers = await _firebaseFirestore.collection(gender == Gender.men? Gender.women.name: Gender.men.name)
                      .where('online', isEqualTo: true)
                      .where('number', isLessThan: random)
                      .limit(limit!)
                      .get()
                      
                      .then((snap) => snap.docs.map((doc) => User.fromSnapshoot(doc)).toList());
      var secondUsersback = users;
      secondUsers.removeWhere((user) => viewedMatches.contains(user.id));
      users.addAll(secondUsers);

      }

      if(users.length <limit && limit>=10){
        recentUsers = await _firebaseFirestore.collection(gender == Gender.men? Gender.women.name: Gender.men.name)
                      .orderBy('lastSeen', descending: true)
                      .limit(limit)
                      .get()
                      .then((snap) => snap.docs.map((doc) => User.fromSnapshoot(doc)).toList());

        var recentBackup= recentUsers;
        recentUsers.removeWhere((user) => viewedMatches.contains(user.id));
        users.addAll(recentUsers);
        if(users.length <10){
          //void viewedNotLikedUsers = firstUsers.removeWhere((user) => viewedProfiles.contains({'id': user.id, 'liked':true}) );
          users.addAll(firstUsers);
          users.addAll(secondUsers);
          users.removeWhere((element) => likedMatches.contains(element.id));

          if(users.length < 10){
            recentBackup.removeWhere((user) => likedMatches.contains(user.id));
            users.addAll(recentBackup);
            if(users.length<10){
              return users;
            }else{
              return users.sublist(0,10);
            }
          }else{
            return users.sublist(0,10);
          }

        }else{
          return users.sublist(0,10);

        }
      }
      
      return users;
      
      
    } catch (e) {
      throw Exception(e);
      
    }
  }

  reportMatch({required String userId, required Gender gender,required UserMatch reportedUser, required int index, 
              required String reportName, required String description})async {

                try {
                  await _firebaseFirestore.collection('report')
                        
                        .add({
                          'reportName': reportName,
                          'reportIndex': index,
                          'description': description,
                          'reportedBy': {'id': userId,'gender':gender.name},
                          'reportedUser': {'id': reportedUser.id,'gender':reportedUser.gender},
                          'timestamp': FieldValue.serverTimestamp()
                        });

                  _firebaseFirestore.collection(gender.name)
                    .doc(userId)
                    .collection('matches')
                    .doc(reportedUser.id)
                    .delete();

                  
                } catch (e) {
                  throw Exception(e);
                }
              }

    FutureOr<User?> getRandomMatch({required String userId, required Gender gender}) async {
    try {
      //final noOfUsers = await _firebaseFirestore.collection(gender == Gender.men? Gender.women.name:Gender.men.name).count().get().then((value) => value.count, onError: (e)=>print('error counting'));
      //var random = Random().nextInt(noOfUsers);
      var random = Random().nextInt(10000000); 
      //random = 25;
    
      User? user =  await _firebaseFirestore.collection(gender == Gender.men? Gender.women.name: Gender.men.name)
              .where('adminChoice', isEqualTo: null)
              .where('number', isGreaterThanOrEqualTo:random )
              .limit(1)
              .get().then((snap) { 
                var result =  snap.docs;
                if(result.isNotEmpty){
                  return User.fromSnapshoot(result.first);
                }else{
                  return null;
                }
                 });

    
        user ??=  await _firebaseFirestore.collection(gender == Gender.men? Gender.women.name: Gender.men.name)
              .where('adminChoice', isEqualTo: null)
              .where('number', isLessThan:random )
              .limit(1)
              .get().then((snap) { 
                var result =  snap.docs;
                if(result.isNotEmpty){
                  return User.fromSnapshoot(result.first);
                }else{
                  return null;
                }
                 });

      
          
          return user;
      
    } catch (e) {
      throw e;
      
    }

  }

  Future<User>getQueen({required String userId, required Gender gender}) async{
    try {
   
        final noOfQueens = await _firebaseFirestore.collection(gender == Gender.women? 'queens' : 'kings').count().get().then((value) => value.count, onError: (e)=>print('error counting'));
        var rand = Random().nextInt(noOfQueens);
        return await _firebaseFirestore.collection('queens')
                .where('queenNumber', isGreaterThanOrEqualTo: rand)
                .get().then((value) => User.fromSnapshoot(value.docs.first));


   


      
    } catch (e) {
      throw e;
      
    }
  }

  Future<User>getPrincess({required String userId, required Gender gender}) async{
    try {
      final noOfUsers = await _firebaseFirestore.collection(gender == Gender.men? Gender.women.name:Gender.men.name)
      .where('adminChoice', isEqualTo: gender == Gender.men? 'princess': 'gent' )
      .count().get().then((value) => value.count, onError: (e)=>print('error counting'));
      var random = Random().nextInt(noOfUsers);
      String field = gender == Gender.men?'gentNumber': 'princessNumber';

      return await _firebaseFirestore.collection(gender == Gender.men? Gender.women.name:Gender.men.name)
                      .where(gender == Gender.men?'princessNumber' : 'gentNumber', isEqualTo: random)
                      .get()
                      .then((value) => User.fromSnapshoot(value.docs.first));
      
      
    } catch (e) {
      throw e;
      
    }
  }

  Future<User?> findMeOnHabeshaWe({required String id, required Gender gender}) async {
    try {
      return await _firebaseFirestore.collection(gender == Gender.men? Gender.women.name: Gender.men.name)
                        .where('id', isEqualTo: id)
                        .get()
                        .then((value) {
                          if(value.docs.isNotEmpty){
                            return User.fromSnapshoot(value.docs.first);
                          }
                          else{
                            return null;
                          }
                        });
      
    } catch (e) {
      throw e;
      
    }
  }

  Future<void> addToQueensKings(User user) async{
    var userMap = user.toMap();
    final count = await _firebaseFirestore.collection(user.gender == Gender.men.name? 'kings':'queens').count().get().then((value) => value.count);
    userMap[user.gender == Gender.men.name?'kingNumber': 'queenNumber'] = count+1;
    await _firebaseFirestore.collection(user.gender)
              .doc(user.id)
              .update({
                'adminChoice': user.gender == Gender.men.name? 'king':'queen',
                user.gender == Gender.men.name?'kingNumber': 'queenNumber': count+1
              });
              
    await _firebaseFirestore.collection(user.gender == Gender.men.name? 'kings':'queens').doc(user.id).set(userMap);

  }

  Future<void> addPrincessOrGent(User user) async{
   // var userMap = user.toMap();
    final count = await _firebaseFirestore.collection(user.gender)
      .where('adminChoice', isEqualTo: user.gender==Gender.men.name?'gent':'princess')
     .count().get().then((value) => value.count);
    //userMap[user.gender == Gender.men.name?'gentNumber': 'princessNumber'] = count+1;
    await _firebaseFirestore.collection(user.gender)
              .doc(user.id)
              .update({
                'adminChoice': user.gender == Gender.men.name? 'gent':'princess',
                user.gender == Gender.men.name?'gentNumber': 'princessNumber': count+1
              });

  }

  void deleteMessage({required Message message, required bool deletealso, required Gender gender}) async{
    try {

      await _firebaseFirestore.collection(gender.name)
        .doc(message.senderId)
        .collection('matches')
        .doc(message.receiverId)
        .collection('chats')
        .doc('chat')
        .collection('messages')
        .doc(message.id)
        .delete();

      if(deletealso){
        await _firebaseFirestore.collection(gender == Gender.men?Gender.women.name: Gender.men.name)
        .doc(message.receiverId)
        .collection('matches')
        .doc(message.senderId)
        .collection('chats')
        .doc('chat')
        .collection('messages')
        .doc(message.id)
        .delete();
      }


      
    } catch (e) {
      throw Exception(e);
      
    }
  }

  void editMessage({required Message message, required Gender gender,required String newMessage}) async {
    try {
      await _firebaseFirestore.collection(gender.name)
            .doc(message.senderId)
            .collection('matches')
            .doc(message.receiverId)
            .collection('chats')
            .doc('chat')
            .collection('messages')
            .doc(message.id)
            .update({
              'message': newMessage
            });

      await _firebaseFirestore.collection(gender == Gender.men?Gender.women.name: Gender.men.name)
            .doc(message.receiverId)
            .collection('matches')
            .doc(message.senderId)
            .collection('chats')
            .doc('chat')
            .collection('messages')
            .doc(message.id)
            .update({
              'message': newMessage
            });
      
    } catch (e) {
      
    }
  }

  void deleteAccount({required String userId, Gender? gender})async {
    try {
      await _firebaseFirestore.collection(gender!.name).doc(userId).delete();
     // await _firebase

      
    } catch (e) {
      
    }
  }

  Future<void> boostMe(User user) async {
    try {
      await _firebaseFirestore.collection('boosted')
        .doc(user.gender)
        .collection('boosted')
        .doc(user.id)
        .set(
          {
            
            'timestamp': FieldValue.serverTimestamp(),
            'user': user.toMap()
          }
        );

      Future.delayed(Duration(hours: 1), ()async{
        await _firebaseFirestore.collection('boosted')
          .doc(user.gender)
          .collection('boosted')
          .doc(user.id)
          .delete();
      });
      
    } catch (e) {
      throw(Exception(e));
      
    }
  }

}



