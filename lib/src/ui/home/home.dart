import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lomi/src/Blocs/AuthenticationBloc/bloc/auth_bloc.dart';
import 'package:lomi/src/Data/Repository/Database/database_repository.dart';
import 'package:lomi/src/ui/Likes/likes.dart';
import 'package:lomi/src/ui/home/ExplorePage.dart';
import 'package:lomi/src/ui/matches/matches_screen.dart';
import 'package:lomi/src/ui/onboarding/onboardAllScreens.dart';

import '../UserProfile/userprofile.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    super.didChangeAppLifecycleState(state);

    if(state == AppLifecycleState.resumed){
      //online
      context.read<DatabaseRepository>().updateOnlinestatus(
        userId: context.read<AuthBloc>().state.user!.uid, 
        gender: context.read<AuthBloc>().state.accountType!, 
        online: true
        );

    }
    if(state == AppLifecycleState.paused){
      //offline
      context.read<DatabaseRepository>().updateOnlinestatus(
        userId: context.read<AuthBloc>().state.user!.uid, 
        gender: context.read<AuthBloc>().state.accountType!, 
        online: false
        );

    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }


  int pageIndex = 0;
 
  
  @override
  Widget build(BuildContext context) {
     bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      //backgroundColor: Colors.transparent,
      appBar: appBar(isDark),
      body: HomeBody(),
    );

    
  }

  AppBar appBar(bool isDark) {
    //bool isDark = Theme.of(context).brightness == Brightness.dark;
    var items = [
      pageIndex == 0 ? 'assets/images/explore_active_icon.svg' :'assets/images/explore_icon.svg',
      pageIndex == 1 ? 'assets/images/likes_active_icon.svg' :'assets/images/likes_icon.svg',
      pageIndex == 2 ? 'assets/images/chat_active_icon.svg' :'assets/images/chat_icon.svg',
      pageIndex == 3 ? 'assets/images/account_active_icon.svg' :'assets/images/account_icon.svg',

    ];
    return AppBar(
      backgroundColor: Colors.transparent,
      leading: null,
      automaticallyImplyLeading: false,
      elevation: 0,
      systemOverlayStyle: 
     // isDark? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
      SystemUiOverlayStyle(
        systemNavigationBarColor: isDark ? Colors.grey[900]: Colors.white, //Color.fromARGB(51, 182, 180, 180)
        systemNavigationBarIconBrightness: !isDark? Brightness.dark: Brightness.light,
      ),
      title: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(items.length, (index) {
            return IconButton(
              onPressed: (){
                setState(() {
                  pageIndex = index;
                });
              }, 
              icon: SvgPicture.asset(items[index])
              );

          })
        ),
      ),

    );
  }


Widget HomeBody(){
  return IndexedStack(
    index: pageIndex,
    children:  [
      ExplorePage(),
      LikesScreen(),
      MatchesScreen(),
      UserProfile() 
    ],
  );
}
}