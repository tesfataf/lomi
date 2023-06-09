import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:line_icons/line_icons.dart';
import 'package:lomi/src/Data/Models/model.dart';
import 'package:lomi/src/Data/Repository/Database/database_repository.dart';
import 'package:lomi/src/ui/editProfile/editProfile.dart';
import 'package:lomi/src/ui/settings/settings.dart';

import '../../Blocs/ProfileBloc/profile_bloc.dart';
import '../../Data/Repository/Authentication/auth_repository.dart';

class UserProfile extends StatelessWidget {
  const UserProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if(state is ProfileLoading){
            return const Center(
              child:  CircularProgressIndicator(),
            );
          }
          
          if(state is ProfileLoaded){
          return Column(
            children: [
              SizedBox(
                height: 40,
              ),
              Center(
                child: SizedBox(
                  height: 200,
                  width: 200,
                  child: Stack(
                    children: [
                      Center(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(width: 4, color: Colors.green),
                            shape: BoxShape.circle,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircleAvatar(
                              backgroundImage:
                                  NetworkImage( 
                                    state.user.imageUrls == null ?
                                    null
                                    :
                                    state.user.imageUrls[0]
                                    
                                    ),
                              radius: 80,
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: ElevatedButton(
                            onPressed: () {
                              context.read<DatabaseRepository>().getUsersBasedonPreference(state.user.id);
                            },
                            style: ElevatedButton.styleFrom(
                                // backgroundColor: Colors.green,
                                shape: StadiumBorder()),
                            child: Text("10% COMPLETE")),
                      ),
                      Positioned(
                        right: 0,
                        top: 30,
                        child: FloatingActionButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfile()));
                          },
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.edit,
                            color: Colors.black,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${state.user.name}, ${state.user.age}',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(fontSize: 18),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Icon(Icons.verified_outlined)
                ],
              ),
              SizedBox(
                height: 50,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.135,
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 10,
                              ),
                              Icon(
                                Icons.star,
                                color: Colors.blue,
                              ),
                              SizedBox(
                                height: 13,
                              ),
                              Text('0 Super Likes'),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                "GET MORE",
                                style: TextStyle(color: Colors.blue),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.135,
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 10,
                              ),
                              Icon(
                                Icons.electric_bolt,
                                color: Colors.purple,
                              ),
                              SizedBox(
                                height: 13,
                              ),
                              Text('My Boosts'),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                "GET MORE",
                                style: TextStyle(color: Colors.blue),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.135,
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 20,
                              ),
                              Icon(
                                LineIcons.lemon,
                                color: Colors.green,
                                size: 30,
                              ),
                              SizedBox(
                                height: 13,
                              ),
                              Text('Subscriptions'),
                              // SizedBox(height: 5,),
                              //Text("GET MORE",style: TextStyle(color: Colors.blue),)
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Spacer(),
              Center(
                child: Container(
                  child: Column(
                    children: [
                      Text(
                        "Lomi Gold and Platinum \nNOT Avaiable",
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: StadiumBorder(),
                            ),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => Settings()));
                            },
                            child: Text(
                              "Buy me Coffee",
                            )),
                      )
                    ],
                  ),
                ),
              ),

              
              Spacer(),
              // FloatingActionButton(
              //   onPressed: (){
              //     Navigator.push(context, MaterialPageRoute(builder: (context) => Settings()));
              //   },
              //   child: Icon(Icons.settings),
              //   ),
            ],
          );
        }else{ return Text('somethisngs went wrong');}
        },
      ),
    );
  }
}
