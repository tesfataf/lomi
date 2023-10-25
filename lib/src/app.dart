import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lomi/src/Blocs/AuthenticationBloc/bloc/auth_bloc.dart';
import 'package:lomi/src/Blocs/ChatBloc/chat_bloc.dart';
import 'package:lomi/src/Blocs/ImagesBloc/images_bloc.dart';
import 'package:lomi/src/Blocs/InternetBloc/internet_bloc.dart';

import 'package:lomi/src/Blocs/ContinueWith/continuewith_cubit.dart';
import 'package:lomi/src/Blocs/ThemeCubit/theme_cubit.dart';
import 'package:lomi/src/Blocs/UserPreference/userpreference_bloc.dart';
import 'package:lomi/src/Blocs/blocs.dart';

import 'package:lomi/src/Data/Models/user_model.dart';
import 'package:lomi/src/Data/Repository/Authentication/auth_repository.dart';
import 'package:lomi/src/Data/Repository/Database/database_repository.dart';
import 'package:lomi/src/Data/Repository/Payment/payment_repository.dart';
import 'package:lomi/src/Data/Repository/Storage/storage_repository.dart';
import 'package:lomi/src/app_route_config.dart';
import 'package:lomi/src/dataApi/explore_json.dart';
import 'package:lomi/src/ui/Profile/profile.dart';
import 'package:lomi/src/ui/editProfile/editProfile.dart';
import 'package:lomi/src/ui/home/home.dart';
import 'package:lomi/src/ui/onboarding/phone.dart';
import 'package:lomi/src/ui/onboarding/start.dart';
import 'package:lomi/src/ui/onboarding/verificationscreen.dart';
import 'package:lomi/src/wrapper.dart';
import 'package:lomi/theme/theme_constants.dart';

import 'Blocs/PaymentBloc/payment_bloc.dart';
import 'Blocs/PhoneAuthBloc/phone_auth_bloc.dart';
import 'Blocs/SharedPrefes/sharedpreference_cubit.dart';
import 'ui/UserProfile/userprofile.dart';
import 'ui/onboarding/AfterRegistration/addphotos.dart';
import 'ui/onboarding/AfterRegistration/birthday.dart';
import 'ui/onboarding/AfterRegistration/enablelocation.dart';
import 'ui/onboarding/AfterRegistration/genderscreen.dart';
import 'ui/onboarding/AfterRegistration/lookingfor.dart';
import 'ui/onboarding/AfterRegistration/namescreen.dart';
import 'ui/onboarding/AfterRegistration/schoolname.dart';
import 'ui/onboarding/AfterRegistration/showme.dart';
import 'ui/onboarding/AfterRegistration/interests.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    //var users = explore_json;
    //users = users.map((user) => UserModel.fromJson(user)).toList();

    return MultiRepositoryProvider(
      providers: [
      RepositoryProvider(create: (context) => AuthRepository()),
      RepositoryProvider(create: (context) => DatabaseRepository()),
      RepositoryProvider(create: (context) => StorageRepository()),
    ],
      child: MultiBlocProvider(
          providers: [
            BlocProvider(lazy: false, create: (context) => InternetBloc()),
            BlocProvider(lazy:false, create: (context) => AuthBloc(authRepository: context.read<AuthRepository>(), databaseRepository: context.read<DatabaseRepository>() )),
            // BlocProvider(
            //     lazy: false,
            //     create: (context) =>
            //         SwipeBloc(
            //           databaseRepository: context.read<DatabaseRepository>(),
            //           authBloc: context.read<AuthBloc>(),
            //         )),

            // BlocProvider(
            //   create: (context) => OnboardingBloc(databaseRepository: context.read<DatabaseRepository>(), storageRepository: context.read<StorageRepository>(), authBloc: context.read<AuthBloc>()),          
            // ),
            BlocProvider<ContinuewithCubit>(create: (context) => ContinuewithCubit(authRepository: context.read<AuthRepository>())),
            // BlocProvider(lazy: false, create: (context) => LikeBloc(databaseRepository: context.read<DatabaseRepository>(), authBloc: context.read<AuthBloc>()) ),
            // BlocProvider( create: (context) => ProfileBloc(authBloc: context.read<AuthBloc>(), databaseRepository: context.read<DatabaseRepository>(), storageRepository: context.read<StorageRepository>())) ,

            //BlocProvider(lazy: false, create: (context) => MatchBloc(databaseRepository: context.read<DatabaseRepository>(), authBloc: context.read<AuthBloc>()) ),
            // BlocProvider(create: ((context) => ChatBloc(databaseRepository: context.read<DatabaseRepository>(), authBloc:  context.read<AuthBloc>()))),
            // BlocProvider( create: (context) => UserpreferenceBloc(databaseRepository: context.read<DatabaseRepository>(), authBloc: context.read<AuthBloc>())),
            BlocProvider(create: ((context) => PhoneAuthBloc(authRepository: context.read<AuthRepository>()))),

            BlocProvider(lazy:false, create: (context) => ThemeCubit()),
            BlocProvider(lazy: false, create: (contet) => SharedpreferenceCubit()..getMyLocation()),
           // BlocProvider(create: (context) => PaymentBloc(paymentRepository: PaymentRepository(), authBloc: context.read<AuthBloc>(), databaseRepository: context.read<DatabaseRepository>() ) ),
            
          ],
          child: BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, state) {
              return ScreenUtilInit(
                
                minTextAdapt: true,
                splitScreenMode: true,
                builder: (_, child) {
                  return MaterialApp(
                          debugShowCheckedModeBanner: false,
                          theme: lightTheme,
                          darkTheme: darkTheme,
                          themeMode: state,
                          //routeInformationParser: LomiAppRouter.router .routeInformationParser,
                          //routerDelegate: LomiAppRouter.router.routerDelegate,
                          //home: AddPhotos(),
                          //routerConfig: LomiAppRouter.returnRouter(),
                          initialRoute: '/',
                          routes: {
                            '/':(context) => const Wrapper(),
                            //'/start' : (context) =>  StartScreen()
                  
                          },
                        );
                }
              );
            },
          )),
    );
  }
}
