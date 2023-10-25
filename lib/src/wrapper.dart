import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lomi/src/Blocs/AdBloc/ad_bloc.dart';
import 'package:lomi/src/Data/Models/enums.dart';
import 'package:lomi/src/Data/Repository/Authentication/auth_repository.dart';
import 'package:lomi/src/Data/Repository/Database/ad_repository.dart';
import 'package:lomi/src/Data/Repository/Database/database_repository.dart';
import 'package:lomi/src/ui/home/home.dart';
import 'package:lomi/src/ui/onboarding/onboardAllScreens.dart';
import 'package:lomi/src/ui/onboarding/start.dart';
import 'package:lomi/src/ui/splash/splashscreen.dart';

import 'Blocs/AuthenticationBloc/bloc/auth_bloc.dart';
import 'Blocs/ThemeCubit/theme_cubit.dart';
import 'Blocs/blocs.dart';
import 'Data/Repository/Payment/payment_repository.dart';
import 'Data/Repository/Storage/storage_repository.dart';
class Wrapper extends StatelessWidget{
  const Wrapper({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state){
        if(state.status == AuthStatus.unknown){
          return const SplashScreen();
        }
        if(state.status == AuthStatus.unauthenticated){
          return BlocBuilder<ThemeCubit,ThemeMode>(

        builder: (context,state) {
          return  StartScreen();
        });
      
        }
        if(state.status == AuthStatus.authenticated){
          //context.read<AuthRepository>().signOut();
          if(state.accountType == Gender.nonExist || !state.isCompleted!){
            return BlocProvider(
              lazy: false,
              create: (context) => OnboardingBloc(databaseRepository: context.read<DatabaseRepository>(), storageRepository: context.read<StorageRepository>(), authBloc: context.read<AuthBloc>()),   
              child: const  WelcomeScreen(),       
            );
            
          }

          context.read<DatabaseRepository>().updateOnlinestatus(userId: state.user!.uid, gender: state.accountType!, online: true);
          
          return MultiBlocProvider(
            providers: [
              BlocProvider(lazy: false,create: (context)=> AdBloc(adRepository: AdRepository())),
              BlocProvider(lazy: false, create: (context) =>
                    SwipeBloc(databaseRepository: context.read<DatabaseRepository>(), authBloc: context.read<AuthBloc>(), adBloc: context.read<AdBloc>())),
              
              BlocProvider(lazy: false, create: (context) => LikeBloc(databaseRepository: context.read<DatabaseRepository>(), authBloc: context.read<AuthBloc>())..add(LoadLikes(userId: state.user!.uid, users: state.accountType!)) ),
              BlocProvider(lazy: false, create: (context) => MatchBloc(databaseRepository: context.read<DatabaseRepository>(), authBloc: context.read<AuthBloc>())..add(LoadMatchs(userId: state.user!.uid, users: state.accountType!)) ),
              BlocProvider(lazy: false, create: (context) => ProfileBloc(authBloc: context.read<AuthBloc>(), databaseRepository: context.read<DatabaseRepository>(), storageRepository: context.read<StorageRepository>())) ,
              BlocProvider(lazy:false, create: ((context) => ChatBloc(databaseRepository: context.read<DatabaseRepository>(), authBloc:  context.read<AuthBloc>(), storageRepository: context.read<StorageRepository>() ))),
              BlocProvider(lazy: false, create: (context) => UserpreferenceBloc(databaseRepository: context.read<DatabaseRepository>(), authBloc: context.read<AuthBloc>())..add(LoadUserPreference(userId: state.user!.uid, users: state.accountType!))),
              BlocProvider(lazy:false,create: (context) => PaymentBloc(paymentRepository: PaymentRepository(), authBloc: context.read<AuthBloc>(), databaseRepository: context.read<DatabaseRepository>() ) ),

            ], 

            child:  const Home());
        }else{
          return Container();
        }
      }
    );

}
}