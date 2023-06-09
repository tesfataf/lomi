import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:lomi/src/Blocs/AuthenticationBloc/bloc/auth_bloc.dart';
import 'package:lomi/src/Blocs/blocs.dart';
import 'package:lomi/src/Blocs/ContinueWith/continuewith_cubit.dart';
import 'package:lomi/src/Data/Models/model.dart';
import 'package:lomi/src/Data/Repository/Database/database_repository.dart';
import 'package:lomi/src/app_route_config.dart';

import '../../Data/Models/userpreference_model.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: 
    Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.green,
          
          Color.fromARGB(255, 13, 66, 15),
          
        ])
      ),
      child: Container(
        child: Column(
         // crossAxisAlignment: CrossAxisAlignment.start,
         mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(height: 100,),
            Padding(
              padding: EdgeInsets.all(8),
              child: Text("Lomi", 
                  style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: Colors.white, ),
              ),

              ),

              SizedBox(height: 70,),
             

              Column(
                //mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  
                  Container(
                    
                    
                    margin: EdgeInsets.symmetric(horizontal: 40),
                    child: Text('By clicking Log In, you agree with our Terms. Learn how we process your data in our Privacy Policy and Cookies Policy.',
                    style: TextStyle(color: Colors.white, fontSize: 12,
             
                    ),
                    textAlign: TextAlign.center,
                    ),
                  ),

                  

                  // Container(
                  //   width: MediaQuery.of(context).size.width * 0.8,
                  //   height: 50,
                  //   child: ElevatedButton.icon(
                      
                  //     onPressed: (){}, 
                  //     icon: Icon(Icons.login,color: Colors.green,), 
                  //     label: Text("Sign In with Google", style: TextStyle(color: Colors.black,fontWeight: FontWeight.w300,fontSize: 15),),
                  //     style: ButtonStyle(
                  //       backgroundColor: MaterialStateProperty.all(Colors.white),
                  //      // textStyle: MaterialStateProperty.all(TextStyle(color: Colors.black)),
                  //     ),
                  //     ),
                  // ),
                  // SizedBox(height: 20,),

                  // Container(
                  //   width: MediaQuery.of(context).size.width * 0.8,
                  //   height: 50,
                  //   child: ElevatedButton.icon(
                      
                  //     onPressed: (){}, 
                  //     icon: Icon(Icons.login,color: Colors.green,), 
                  //     label: Text("Sign In with Facebook", style: TextStyle(color: Colors.black,fontWeight: FontWeight.w300,fontSize: 15),),
                  //     style: ButtonStyle(
                  //       backgroundColor: MaterialStateProperty.all(Colors.white),
                  //      // textStyle: MaterialStateProperty.all(TextStyle(color: Colors.black)),
                  //     ),
                  //     ),
                  // ),
                  SizedBox(height: 20,),

                  // signin_button(context),
                  // SizedBox(height: 20,),
                  // signin_button(context),
                  // SizedBox(height: 20,),
                  // signin_button(context),
                //   Container(
              
                //   width: MediaQuery.of(context).size.width * 0.8,
                //   height: 50,
                //   child: ElevatedButton(

                //     onPressed: () async{
                //      // BlocProvider.of<AuthBloc>(context).add(LogInWithGoogle());
                //      // final nextstate = await AuthBloc.s
                      
                //       //await context.read<AuthBloc>().add(LogInWithGoogle());

                //       await context.read<ContinuewithCubit>().continueWithGoogle();
                //       if(!await context.read<DatabaseRepository>().isUserAlreadyRegistered(context.read<ContinuewithCubit>().state.user!.uid)){

                      
                //       User user = User(
                //         id: context.read<ContinuewithCubit>().state.user!.uid,
                //         name: '', age: 0, gender: '', imageUrls: [], interests: []
                //         );
                      
                //       //if(Paint.enableDithering)
                //       context.read<OnboardingBloc>().add(StartOnBoarding(user: user));
                //       GoRouter.of(context).pushNamed(MyAppRouteConstants.phoneRouteName);

                //       }else{
                //         //GoRouter.of(context).pushNamed(MyAppRouteConstants.homeRouteName);
                //       //  await context.read<DatabaseRepository>().updateUserPreference(
                //       //     context.read<ContinuewithCubit>().state.user!.uid, 
                //       //     UserPreference(phoneNumber: '251703398088', showMe: 'women'));
                //       }

                //     }, 
                //     style: ButtonStyle(
                //       backgroundColor: MaterialStateProperty.all(Colors.white),
                //       shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                //         RoundedRectangleBorder(
                //           borderRadius: BorderRadius.circular(30.0),
                //         )
                //       ),
                //     ),
                //     child: Row(
                //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //       children: [
                //         Icon(Icons.face, color: Colors.red,),
                //         Text("LOG IN WITH PHONE NUMBER", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w400, fontSize: 12,)),
                //         SizedBox(width: 10,)
                        
                //       ],
                //     ),
                //     ),
                // ),

                signInButton(
                  context: context, 
                  text: "LOG IN WITH GOOGLE", 
                  icon: FontAwesomeIcons.google,
                  color: Colors.red, 
                  onPressed: ()async{
                     // BlocProvider.of<AuthBloc>(context).add(LogInWithGoogle());
                     // final nextstate = await AuthBloc.s
                      
                      //await context.read<AuthBloc>().add(LogInWithGoogle());

                      await context.read<ContinuewithCubit>().continueWithGoogle();
                      if(!await context.read<DatabaseRepository>().isUserAlreadyRegistered(context.read<AuthBloc>().state.user!.uid)){

                      
                      User user = User(
                        id: context.read<ContinuewithCubit>().state.user!.uid,
                        name: '', age: 0, gender: '', imageUrls: [], interests: []
                        );
                      
                      //if(Paint.enableDithering)
                      context.read<OnboardingBloc>().add(StartOnBoarding(user: user));
                      GoRouter.of(context).pushNamed(MyAppRouteConstants.phoneRouteName);

                      }else{
                        //GoRouter.of(context).pushNamed(MyAppRouteConstants.homeRouteName);
                      //  await context.read<DatabaseRepository>().updateUserPreference(
                      //     context.read<ContinuewithCubit>().state.user!.uid, 
                      //     UserPreference(phoneNumber: '251703398088', showMe: 'women'));
                      }

                    },
                  ),

                  SizedBox(height: 15,),

                  signInButton(
                  context: context, 
                  text: "LOG IN WITH FACEBOOK", 
                  icon: FontAwesomeIcons.facebook, 
                  color: Colors.blue,
                  onPressed: (){}
                  ),
                  SizedBox(height: 15,),
                  signInButton(
                  context: context, 
                  text: "LOG IN WITH PHONE NUMBER", 
                  icon: FontAwesomeIcons.phone, 
                  color: Colors.grey,
                  onPressed: (){
                    //context.read<DatabaseRepository>().getUsersBasedonPreference('userId');
                  }
                  ),
                  SizedBox(height: 25,),
                  Center(child: Text('Trouble logging in?', style: TextStyle(color: Colors.white),),)
                ],
              )
          ],
        ),
      ),
    ),
    );
  }

  Container signInButton({required BuildContext context,required String text,required IconData icon,required Color color,required void Function() onPressed}) {
    return Container(
              
                  width: MediaQuery.of(context).size.width * 0.85,
                  height: 50,
                  child: ElevatedButton(

                    onPressed: onPressed,
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.white),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        )
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left:5.0),
                          child: Icon(icon, 
                          color: color,
                          size: 17,
                          ),
                        ),
                        Text(text, 
                        style: TextStyle(color: Colors.black.withOpacity(0.4), fontWeight: FontWeight.bold, fontSize: 13,)),
                        SizedBox(width: 10,)
                        
                      ],
                    ),
                    
                    ),
                );
  }
}