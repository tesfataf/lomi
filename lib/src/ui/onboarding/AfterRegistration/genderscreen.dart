import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:line_icons/line_icons.dart';
import 'package:lomi/src/app_route_config.dart';

import '../../../Blocs/OnboardingBloc/onboarding_bloc.dart';

// class GenderScreen extends StatefulWidget {
//   const GenderScreen({super.key});

//   @override
//   State<GenderScreen> createState() => _GenderScreenState();
// }

class GenderScreen extends StatelessWidget {
  const GenderScreen({super.key});
  //final bool _isSelected = false;
 // int? _value = 1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<OnboardingBloc, OnboardingState>(
          builder: (context, state) {
            if(state is OnboardingLoading){
              return Center(child: CircularProgressIndicator(),);
            }
            
            if(state is OnboardingLoaded){

            return Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const LinearProgressIndicator(
                        value: 0.3,
        
                      ),
                     const Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(LineIcons.times,size: 35,),
                      ),
        
                      Container(
                        width: 200,
                        margin: EdgeInsets.all(35),
                        child: Text('What\'s your gender?',
                        style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Colors.black),
                        ),
                      ),
                      Spacer(flex: 1,),
                      
        
                      Center(
                        child: Wrap(
                          spacing: 5.0,
                          direction: Axis.vertical,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: List.generate(2, (index){
                            return Center(
                              child: ChoiceChip(
                                label: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width*0.7,
                                    child: Text(index == 0 ?' Men  ': 'Women', textAlign: TextAlign.center,)),
                                ), 
                                selected: index == 0 ? state.user.gender == 'Men' ? true : false : state.user.gender == 'Women' ? true: false,
                                onSelected: (value) {
                                  context.read<OnboardingBloc>().add(EditUser(user: state.user.copyWith(gender: index == 0? 'Men':'Women')));
                                  // setState(() {
                                  //   _value = value ? index : null;
                                  // });
                                },
                                selectedColor: Colors.green.withOpacity(0.6),
                                
                              ),
                            );
                          }
                          ).toList(),
                      
                        ),
                      ),
        
        
        
                      Spacer(flex: 2,),
                      Center(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width*0.70,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: (){
                              GoRouter.of(context).pushNamed(MyAppRouteConstants.birthdayRouteName);
                            }, 
                            child: Text('CONTINUE', style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 17,color: Colors.white),),
                            style: ElevatedButton.styleFrom(
                              shape: StadiumBorder(),
                            ),
                            
                            ),
                        ),
                      ),
                      const SizedBox(height: 20,)
                     
        
                    ],
                  ),
                );
            }
            else{
              return Text('something went wrong');
            }
          },
        )
      )
    );

  }
}