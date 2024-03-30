part of 'new_user_profile_bloc.dart';

@immutable
sealed class NewUserProfileEvent {}

class AddProfileImageEvent extends NewUserProfileEvent {}

class AddProfileVideoEvent extends NewUserProfileEvent {}

class SubmitProfileEvent extends NewUserProfileEvent {}

class AddDOBEvent extends NewUserProfileEvent {}
