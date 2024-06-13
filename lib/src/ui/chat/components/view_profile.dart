import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lomi/src/Data/Models/enums.dart';
import 'package:lomi/src/Data/Models/likes_model.dart';
import 'package:lomi/src/Data/Models/model.dart';
import 'package:lomi/src/Data/Repository/Database/database_repository.dart';
import 'package:lomi/src/ui/Profile/components/body.dart';
import 'package:swipable_stack/swipable_stack.dart';
import 'package:swipe_cards/swipe_cards.dart';



class ViewProfile extends StatelessWidget {

  final ProfileFrom profileFrom;
  final Like? likedMeUser;
  final BuildContext ctrx;
  final UserMatch match;
  

   const ViewProfile({Key? key,required this.match,required this.profileFrom, this.likedMeUser, required this.ctrx }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      
      body: Container(
        child: FutureBuilder(
          future: context.read<DatabaseRepository>().getUserbyId(match.userId, match.gender),
          builder: (context, AsyncSnapshot<User> snapshot){
            if(snapshot.hasError){
              return Center(child: Text('something went wrong, Try again...'),);
            }
            if(snapshot.hasData){
              return Body(user: snapshot.data!, profileFrom: profileFrom, likedMeUser: likedMeUser, matchEngine: null, ctrx: ctrx);
            }else{
              return Center(child: CircularProgressIndicator(strokeWidth: 2,),);
            }
          })
      )

      //body: Body(user: user, profileFrom: profileFrom, likedMeUser: likedMeUser, matchEngine: matchEngine, ctrx: ctrx),
    );
    
  }
}