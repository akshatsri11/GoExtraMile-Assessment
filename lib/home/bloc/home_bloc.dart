import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<HomeNavToNewUserProfile>(homeNavToNewUserProfile);
  }

  FutureOr<void> homeNavToNewUserProfile(
      HomeNavToNewUserProfile event, Emitter<HomeState> emit) {
    log("******");
    emit(HomeNavigateToNewUserProfileActionState());
  }
}
