import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lomi/src/Blocs/ChatBloc/chat_bloc.dart';
import 'package:lomi/src/Data/Models/model.dart';

import '../../../Blocs/MatchBloc/match_bloc.dart';
import '../../chat/chatscreen.dart';
import 'matches_image_small.dart';

class Body extends StatelessWidget {
  const Body({super.key});

  @override
  Widget build(BuildContext context) {
   // final inactiveMatches = UserMatch.matches.where((match) => match.userId == 1 && match.chat!.isEmpty,).toList();
   // final activeMatches = UserMatch.matches.where((match) => match.userId == 1 && match.chat!.isNotEmpty,).toList();


    return SingleChildScrollView(
      child: BlocBuilder<MatchBloc, MatchState>(
        builder: (context, state) {
          if(state is MatchLoading){
            return Center(child: CircularProgressIndicator(),); 
          }
          
          if(state is MatchLoaded){
            final inactiveMatches = state.matchedUsers.where((match) => match.chat== 'notOpened').toList();
            final activeMatches = state.matchedUsers.where((match) => match.chat == 'Opened').toList(); 
            return
           Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("New Matches", style: Theme.of(context).textTheme.bodyLarge,),
              SizedBox(height: 10,),
      
              SizedBox(
                height: 150,
                child: inactiveMatches.length !=0 ? ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: inactiveMatches.length,
                  itemBuilder: (context, index){
                    return InkWell(
                      onTap: (){Navigator.push(context,MaterialPageRoute(builder: (context) => ChatScreen(inactiveMatches[index])));},
                      child: MatchesImage(url: inactiveMatches[index].matchedUser.imageUrls[0], height: 120, width: 100,));
                  }
                  ):
                  Container(
                height: 150,
                width: 120,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(20)
                ),
                child: Center(child: Text('New matches\nwill appear\n here',textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 10,fontWeight: FontWeight.w300),)),
                  ),
              ),
              Padding(
                padding: const EdgeInsets.only(top:8.0, left: 8),
                child: Text("Likes", style: Theme.of(context).textTheme.bodyLarge,),
              ),
              
              SizedBox(height: 25,),
      
              Text("Messages", style: Theme.of(context).textTheme.bodyLarge,),
              SizedBox(height: 25,),
              ListView.builder(
                shrinkWrap: true,
                itemCount: activeMatches.length,
                itemBuilder: (context,index){
                  return InkWell(
                    onTap: (){
                      context.read<ChatBloc>().add(LoadChats(userId: activeMatches[index].userId, matchedUserId: activeMatches[index].matchedUser.id));
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(activeMatches[index]) ));
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MatchesImage(url: activeMatches[index].matchedUser.imageUrls[0],
                           height: 60,width: 60,shape: BoxShape.circle,),
                           Padding(
                             padding: const EdgeInsets.all(8.0),
                             child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                SizedBox(height: 5,),
                                 Text(activeMatches[index].matchedUser.name,
                                      style: Theme.of(context).textTheme.bodyLarge,
                                 
                                 ),
                                const SizedBox(height: 5,),
                                               
                                  Text(
                                    'Hello from the other side',

                                   // activeMatches[index].chat,
                                    //activeMatches[index].chat![0].messages[0].message,
                                      style: Theme.of(context).textTheme.bodySmall,
                                 
                                 ),
                                //  const SizedBox(height: 5,),
                                //  Text(
                                //   activeMatches[index].chat,
                                //   //activeMatches[index].chat![0].messages[0].timeString,
                                //       style: Theme.of(context).textTheme.bodySmall,
                                 
                                //  ),
                               ],
                             ),
                           ),
                           Spacer(),

                           Padding(
                             padding: const EdgeInsets.only(top: 15.0),
                             child: Text('7:03 PM',
                             style: Theme.of(context).textTheme.bodySmall,
                             ),
                           )
                        ],
                      ),
                    ),
                  );
                })
      
      
            ]),
          );

          }else{
            return Text('something went wrong...');
          }
        },
      ),
      );
    
  }
}