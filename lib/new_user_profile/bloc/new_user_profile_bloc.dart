import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'new_user_profile_event.dart';
part 'new_user_profile_state.dart';

class NewUserProfileBloc
    extends Bloc<NewUserProfileEvent, NewUserProfileState> {
  NewUserProfileBloc() : super(NewUserProfileInitial()) {
    on<SubmitProfileEvent>(submitProfileEvent);
    on<AddProfileImageEvent>(addProfileImageEvent);
    on<AddProfileVideoEvent>(addProfileVideoEvent);
    on<AddDOBEvent>(addDOBEvent);
  }

  FutureOr<void> submitProfileEvent(
      SubmitProfileEvent event, Emitter<NewUserProfileState> emit) {
    emit(SubmitProfileActionState());
  }

  FutureOr<void> addProfileImageEvent(
      AddProfileImageEvent event, Emitter<NewUserProfileState> emit) {
    emit(AddProfileImageState());
  }

  FutureOr<void> addProfileVideoEvent(
      AddProfileVideoEvent event, Emitter<NewUserProfileState> emit) {
    emit(AddProfileVideoState());
  }

  FutureOr<void> addDOBEvent(
      AddDOBEvent event, Emitter<NewUserProfileState> emit) {
    emit(AddDOBState());
  }
}
