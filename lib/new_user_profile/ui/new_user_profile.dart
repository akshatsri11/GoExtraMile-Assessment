import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:user_profile/new_user_profile/bloc/new_user_profile_bloc.dart';
import 'package:video_player/video_player.dart';
import 'package:user_profile/new_user_profile/resources/store_data.dart';
import 'package:user_profile/home/ui/home_screen.dart';
import 'package:user_profile/new_user_profile/utils.dart';

class NewUserProfile extends StatefulWidget {
  const NewUserProfile({Key? key}) : super(key: key);

  @override
  State<NewUserProfile> createState() => _NewUserProfileState();
}

class _NewUserProfileState extends State<NewUserProfile> {
  late VideoPlayerController _videoPlayerController;
  String? _videoURL;
  Uint8List? _image;
  String? selectedGender;
  DateTime? _dob;
  bool isSubmit = false;

  final picker = ImagePicker();
  final dobController = TextEditingController();
  final nameController = TextEditingController();

  @override
  void dispose() {
    _videoPlayerController.dispose();
    dobController.dispose();
    nameController.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    _videoURL = await pickVideo();
    if (_videoURL != null) {
      _initializeVideoPlayer();
    }
  }

  void _initializeVideoPlayer() {
    _videoPlayerController = VideoPlayerController.file(File(_videoURL!))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _videoPlayerController.play();
          });
        }
      });
  }

  Widget _videoPreview() {
    return AspectRatio(
      aspectRatio: _videoPlayerController.value.aspectRatio,
      child: VideoPlayer(_videoPlayerController),
    );
  }

  Future<void> _pickImage() async {
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _image = Uint8List.fromList(bytes);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && pickedDate != _dob) {
      setState(() {
        _dob = pickedDate;
        dobController.text = _dob!.toString().substring(0, 10);
      });
    }
  }

  Future<void> saveProfile() async {
    setState(() {
      isSubmit = true;
    });
    final name = nameController.text;
    final gender = selectedGender ?? 'Other';
    final dob = dobController.text;
    final downloadURL = await StoreData().uploadVideoToStorage(_videoURL!);
    final response = await StoreData().saveData(
      fullName: name,
      gender: gender,
      dob: dob,
      image: _image!,
      video: downloadURL,
    );
    log(response);
    setState(() {
      _videoURL = null;
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final NewUserProfileBloc newUserProfileBloc = NewUserProfileBloc();
    return BlocConsumer<NewUserProfileBloc, NewUserProfileState>(
      bloc: newUserProfileBloc,
      listenWhen: (previous, current) => current is NewUserProfileActionState,
      buildWhen: (previous, current) => current is! NewUserProfileActionState,
      listener: (context, state) {
        if (state is SubmitProfileActionState) {
          saveProfile();
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Profile added')));
        }
        if (state is AddProfileImageState) {
          _pickImage();
        }
        if (state is AddProfileVideoState) {
          _pickVideo();
        }
        if (state is AddDOBState) {
          _selectDate(context);
        }
      },
      builder: (context, state) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: const Text("Add New User"),
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Stack(
                  children: [
                    _image != null
                        ? CircleAvatar(
                            backgroundImage: MemoryImage(_image!),
                            radius: 50,
                          )
                        : const CircleAvatar(
                            backgroundImage: AssetImage('assets/avatar.png'),
                            radius: 50,
                          ),
                    Positioned(
                      left: 60,
                      bottom: -10,
                      child: IconButton(
                        onPressed: () {
                          newUserProfileBloc.add(AddProfileImageEvent());
                        },
                        icon: const Icon(
                          Icons.add_a_photo,
                          color: Colors.black,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5)),
                    contentPadding: const EdgeInsets.all(10.0),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your full name' : null,
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  isDense: true,
                  value: selectedGender,
                  onChanged: (value) {
                    setState(() {
                      selectedGender = value;
                    });
                  },
                  items: const ['Male', 'Female', 'Other']
                      .map((gender) => DropdownMenuItem<String>(
                            value: gender,
                            child: Text(gender),
                          ))
                      .toList(),
                  decoration: const InputDecoration(
                    labelText: 'Gender',
                    contentPadding: EdgeInsets.all(10.0),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please select your gender'
                      : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: dobController,
                  readOnly: true,
                  onTap: () => newUserProfileBloc.add(AddDOBEvent()),
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(10.0),
                    labelText: 'Date of Birth',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty
                      ? 'Please select your date of birth'
                      : null,
                ),
                const SizedBox(height: 20),
                _videoURL != null
                    ? SizedBox(height: 150, child: _videoPreview())
                    : const Text("Please pick a video"),
                ElevatedButton(
                  onPressed: () {
                    newUserProfileBloc.add(AddProfileVideoEvent());
                  },
                  child: const Text("Pick a video from gallery"),
                ),
                const Spacer(),
                isSubmit
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () {
                          newUserProfileBloc.add(SubmitProfileEvent());
                        },
                        child: const Text("Submit"),
                      ),
              ],
            ),
          ),
        );
      },
    );
  }
}
