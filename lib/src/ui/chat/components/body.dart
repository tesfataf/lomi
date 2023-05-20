import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lomi/src/Blocs/AuthenticationBloc/bloc/auth_bloc.dart';
import 'package:lomi/src/Data/Models/model.dart';

import '../../../Blocs/ChatBloc/chat_bloc.dart';

class Body extends StatelessWidget {
  const Body(this.userMatch);
  final UserMatch userMatch;

  @override
  Widget build(BuildContext context) {
    String msg= '';
    final msgController = TextEditingController();
    final scrollController = ScrollController();
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        if(state is ChatLoading){
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        
        if(state is ChatLoaded){
          //scrollController.jumpTo(scrollController.position.maxScrollExtent);
        return  Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: state.messages != null ? 
                      Container(
                        child: ListView.builder(
                          
                          //controller: scrollController,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: state.messages!.length,
                          reverse: true,
                          
                          //userMatch.chat![0].messages.length,
                          itemBuilder: ((context, index) {
                            return ListTile(
                              
                              title: state.messages![index].senderId == userMatch.userId ?
                              //userMatch.chat![0].messages[index].senderId == 1? 
                              Align(
                                alignment: Alignment.topRight,
                                child: Container(
                                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.83),
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(20),
                                      topLeft: Radius.circular(20),
                                      topRight: Radius.circular(20)
                                      ),
                                    color: Colors.green.shade200,
                                  ),
                                  child: Text(
                                    state.messages![index].message,                                    
                                    //userMatch.chat![0].messages[index].message,
                                    style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.black)
                                    //TextStyle(color: Colors.black)
                                    ,))
                                ) :
          
                                // Row(
                                //   children: [
                                //     CircleAvatar(
                                      
                                //        backgroundImage: NetworkImage(userMatch.matchedUser.imageUrls[0]),
                  
                                //          ),
                                //          SizedBox(width: 10,),
                                    Align(
                                    alignment: Alignment.topLeft,
                                    child: Container(
                                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.83),
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                      bottomRight: Radius.circular(20),
                                      topLeft: Radius.circular(20),
                                      topRight: Radius.circular(20)
                                      ),
                                        color: Colors.grey.shade200,
                                      ),
                                      child: Text(
                                        state.messages![index].message,
                                        //userMatch.chat![0].messages[index].message,
                                        style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.black),))
                                    ),
                                //   ],
                                // )
          
          
                            );
                          })),
                      ):
                      SizedBox(),
            ),
            
          ),


          
          
    
    
          // Container(
          //   padding: EdgeInsets.symmetric(horizontal: 20),
          //   //height: 100,
          //   child: Row(
          //     crossAxisAlignment: CrossAxisAlignment.end,
          //     children: [
    
          //       Expanded(
          //         child: Container(
          //           decoration: BoxDecoration(
          //             shape: BoxShape.circle,
          //             color: Colors.grey
          //           ),
          //           child: TextField(
          //             onChanged: (value) {
          //               msg = value;
          //             },
          //             decoration: InputDecoration(
          //               filled: true,
          //               fillColor: Colors.white,
          //               hintText: 'Type here...',
          //               contentPadding: const EdgeInsets.only(top: 5, left: 20, bottom: 5 ),
                        
          //             ),
          //             maxLines: 6,
          //             minLines: 1,
          //           ),
          //         ),
          //       ),
    
          //       IconButton(
          //         onPressed: (){
          //           context.read<ChatBloc>().add(SendMessage(message: Message(id: 'id', senderId: context.read<AuthBloc>().state.user!.uid, receiverId: context.read<AuthBloc>().state.user!.uid == state.messages![0].senderId ? state.messages![0].receiverId : state.messages![0].senderId, message: msg, timestamp: DateTime.now())));
          //         }, 
          //         icon: Icon(Icons.send_rounded, color: Colors.green,))
          //     ],
          //   ),
              
          //   )

          Container(
      //height: 60,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              //height: 40,
              width: MediaQuery.of(context).size.width/1.3,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.all(
                  Radius.circular(20)
                ),
              ),
              child:  TextField(
                //keyboardType: TextInputType.,
                controller: msgController,
                maxLines: 6,
                minLines: 1,
                onChanged: (value){
                  msg = value;
                },
                cursorColor: Colors.black,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  //contentPadding: EdgeInsets.zero,
                  hintText: 'Type Here!',
                  
                  //hintStyle: Theme.of(context).textTheme.bodySmall,
                  icon: Padding(
                    padding: const EdgeInsets.all(0),
                    child: Icon(
                      FontAwesomeIcons.faceSmile, 
                      color: Colors.grey,
                      size: 20,
                      ),
                  ),
                    suffix: Icon(
                      FontAwesomeIcons.paperclip,
                      color: Colors.grey,
                      size: 20,
                    )
                ),
              ),
            ),

            SizedBox(width: 7,),

            Container(
              padding: EdgeInsets.only(right: 5),
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green,
              ),
              child: IconButton(
                icon: Icon(FontAwesomeIcons.paperPlane,
                color: Colors.white,
                size: 20,
                ),
                onPressed: ()async{
                  //msg='';
                  
                  context.read<ChatBloc>().add(SendMessage(message: Message(id: 'id', senderId: context.read<AuthBloc>().state.user!.uid, receiverId: context.read<AuthBloc>().state.user!.uid == state.messages![0].senderId ? state.messages![0].receiverId : state.messages![0].senderId, message: msgController.text, timestamp: DateTime.now())));
                  msgController.clear();
                },
              ),
            )
          ],
      
        ),
      ),
    ),
    SizedBox(height: 5,),

            
        ],
      );
        }else{
          return Text('something went wrong...');
        }
      }
    
    );
  }
}