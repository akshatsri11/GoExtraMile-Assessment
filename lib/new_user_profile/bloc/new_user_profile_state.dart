part of 'new_user_profile_bloc.dart';

@immutable
sealed class NewUserProfileState {}

abstract class NewUserProfileActionState extends NewUserProfileState {}

final class NewUserProfileInitial extends NewUserProfileState {}

class SubmitProfileActionState extends NewUserProfileActionState {}

class AddProfileImageState extends NewUserProfileActionState {}

class AddProfileVideoState extends NewUserProfileActionState {}

class AddDOBState extends NewUserProfileActionState {}
