import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:lomi/src/Data/Models/enums.dart';
import 'package:lomi/src/Data/Repository/Authentication/auth_repository.dart';
import 'package:lomi/src/Data/Repository/Database/database_repository.dart';


part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription<auth.User?>? _userSubscription;
  final DatabaseRepository _databaseRepository;
  AuthBloc({
    required AuthRepository authRepository,
    required DatabaseRepository databaseRepository
  }) : _authRepository = authRepository,
       _databaseRepository = databaseRepository,
  super(AuthState.unknown()) {

    _userSubscription = _authRepository.user.listen(
      (user) => add(
          
          AuthUserChanged(user: user)
        )
    );

    on<AuthUserChanged>(_authUserChanged);
    on<LogInWithGoogle>(_onLogInWithGoogle);
    on<LogOut>(_onLogOut);
    on<DeleteAccount>(_onDeleteAccount);
  }


  @override
Future<void> close(){
  _userSubscription?.cancel();
  return super.close();
}


void _authUserChanged(AuthUserChanged event, Emitter<AuthState> emit) async{

  try {
  if(event.user != null ){
    Gender isUserAlreadyRegistered = await _databaseRepository.isUserAlreadyRegistered(event.user!.uid);
    bool isCompleted;
    if(isUserAlreadyRegistered == Gender.nonExist){
      isCompleted = false;
    }else{
     isCompleted = await _databaseRepository.isCompleted(isUserAlreadyRegistered,event.user!.uid);
    }
    
    emit(AuthState.authenticated(user: event.user!,accountType: isUserAlreadyRegistered , isCompleted: isCompleted));
    
  }else{
    emit(AuthState.unauthenticated());
  }
} on Exception catch (e) {
  // TODO
  print(e.toString());
}

}

FutureOr<void> _onLogOut(LogOut event, Emitter<AuthState> emit) async {
  await _databaseRepository.updateOnlinestatus(
                            userId: state.user!.uid, 
                            gender: state.accountType!, 
                            online: false
                             );
  emit(const AuthState.unknown());
  await _authRepository.signOut();
  await HydratedBloc.storage.clear();

}

Future<void> _onLogInWithGoogle(LogInWithGoogle event, Emitter<AuthState> emit) async{
  // try {
  //       final result = await _authRepository.logInWithGoogle();
  //       bool isUserAlreadyRegistered = await DatabaseRepository().isUserAlreadyRegistered(result!.uid);
  //       emit(AuthState.authenticated(user: result!, accountType: !isUserAlreadyRegistered));
        
  //     }on Exception catch (e) {
  //       print(e.toString());
  //     }
}

  // @override
  // AuthState? fromJson(Map<String, dynamic> json) {
  //   // TODO: implement fromJson
  //   return AuthState.fromMap(json);
  // }

  // @override
  // Map<String, dynamic>? toJson(AuthState state) {
  //   // TODO: implement toJson
  //   return  state.toMap();
  //   //state.toJson();
  // }
  


  FutureOr<void> _onDeleteAccount(DeleteAccount event, Emitter<AuthState> emit) {
    try {
      _databaseRepository.deleteAccount(userId: state.user!.uid, gender: state.accountType);
      _authRepository.deleteAccount();
      
    } catch (e) {
      
    }
  }
}




