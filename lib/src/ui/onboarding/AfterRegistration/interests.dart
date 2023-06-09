import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:line_icons/line_icons.dart';
import 'package:lomi/src/Blocs/blocs.dart';
import 'package:lomi/src/app_route_config.dart';
import 'package:lomi/src/dataApi/interestslist.dart';

class Interests extends StatefulWidget {
  const Interests({super.key});

  @override
  State<Interests> createState() => _InterestsState();
}

class _InterestsState extends State<Interests> {
 // bool _isSelected = false;
  List<String> _selectedList = [];
  //OnboardingState st;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child:SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const LinearProgressIndicator(
                  value: 0.8
        
                ),
               const Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(LineIcons.times,size: 35,),
                ),
        
                Container(
                  width: 200,
                  margin: EdgeInsets.symmetric(horizontal:35),
                  child: Text('Intersts',
                 // textAlign: TextAlign.start,
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Colors.black),
                  ),
                ),
                Container(
                    width: MediaQuery.of(context).size.width*0.9,
                    margin: EdgeInsets.only(top: 10,left: 35),
                    child: Text(
                      'Let everyone know what you\'re passionate about \nby adding it to your profile.',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Color.fromARGB(255, 192, 189, 189)),
                      )
                  ),
               // Spacer(flex: 1,),
        
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Wrap(
                    spacing: 5,
                    children: List.generate(inter.length, (index) => 
                        ChoiceChip(
                        label: Text(inter[index],style: TextStyle(color: _selectedList.contains(inter[index])? Colors.white : Colors.black),), 
                        selected: _selectedList.contains(inter[index]),
                        selectedColor: Colors.green,
                       // backgroundColor: Colors.white,
                        onSelected: (value) {
                          setState(() {
                            _selectedList.contains(inter[index]) ? _selectedList.remove(inter[index]) : _selectedList.add(inter[index]);
                          });
                        },
                        ),
                    )
                  ),
                ),
                
        
                
               
        
        
        
               // Spacer(flex: 2,),
                BlocBuilder<OnboardingBloc, OnboardingState>(
                  
                  builder: (context, state) {
                    
                    
                  if (state is OnboardingLoaded){
                  return Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width*0.70,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: (){
                          
                          context.read<OnboardingBloc>().add(UpdateUser(user: state.user.copyWith(interests: _selectedList)));
                          GoRouter.of(context).pushNamed(MyAppRouteConstants.addphotosRouteName);
                        }, 
                        child: Text('CONTINUE', style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 17,color: Colors.white),),
                        style: ElevatedButton.styleFrom(
                          shape: StadiumBorder(),
                        ),
                        
                        ),
                    ),
                  );
                  }
                  else{return Center(child: CircularProgressIndicator(),);}
                  }
                ),
        
               // const SizedBox(height: 20,)
               
        
              ],
            ),
          ),
        )
      )
    );
  }
}