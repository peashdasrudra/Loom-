// lib/features/profile/presentation/pages/edit_profile_page.dart

import 'dart:io' show File;
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loom/features/auth/presentation/components/my_text_field.dart';
import 'package:loom/features/profile/domain/entities/profile_user.dart';
import 'package:loom/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:loom/features/profile/presentation/cubits/profile_states.dart';

class EditProfilePage extends StatefulWidget {
  final ProfileUser user;
  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // mobile image pick
  PlatformFile? imagePickedFile;

  // web image pick
  Uint8List? webImage;

  // bio text controller
  final bioTextController = TextEditingController();

  // pick image
  Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: kIsWeb,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        imagePickedFile = result.files.first;

        if (kIsWeb) {
          webImage = imagePickedFile!.bytes;
        }
      });
      // debug
      print(
        'pickImage: selected file: ${imagePickedFile?.name}, path: ${imagePickedFile?.path}, bytesLength: ${imagePickedFile?.bytes?.length}',
      );
    } else {
      print('pickImage: no file selected');
    }
  } // <-- closed pickImage()

  // update profile button pressed
  Future<void> updateProfile() async {
    print('EditProfilePage.updateProfile called');
    // profile cubit
    final profileCubit = context.read<ProfileCubit>();

    // prepare images & data
    final String uid = widget.user.uid;
    final String? newBio = bioTextController.text.isNotEmpty
        ? bioTextController.text
        : null;
    final imageMobilePath = kIsWeb ? null : imagePickedFile?.path;
    final imageWebBytes = kIsWeb ? imagePickedFile?.bytes : null;

    print(
      'EditProfilePage: uid=$uid newBio=$newBio imageMobilePath=$imageMobilePath bytesLength=${imageWebBytes?.length}',
    );

    // only update profile if there is something to update
    if (imagePickedFile != null || newBio != null) {
      await profileCubit.updateProfile(
        uid: uid,
        newBio: newBio,
        imageMobilePath: imageMobilePath,
        imageWebBytes: imageWebBytes,
      );
      // don't Navigator.pop here — let the cubit's listener decide
    } else {
      // nothing to update → go to previous page
      Navigator.pop(context);
    }
  } // <-- closed updateProfile()

  //Build UI
  @override
  Widget build(BuildContext context) {
    //Scaffold
    return BlocConsumer<ProfileCubit, ProfileState>(
      builder: (context, state) {
        // profile loading
        if (state is ProfileLoading) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('Updating...'),
                ],
              ),
            ),
          );
        } else {
          // edit form
          return buildEditPage();
        }
      },
      listener: (context, state) {
        if (state is ProfileLoaded) {
          // show success and pop back to profile
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Profile updated')));
          Navigator.pop(context);
        } else if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Update failed: ${state.message}')),
          );
        }
      },
    );
  }

  Widget buildEditPage() {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Edit Profile",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        foregroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
        actions: [
          // save button
          IconButton(onPressed: updateProfile, icon: const Icon(Icons.upload)),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // profile picture + tappable + edit icon
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Hero-wrapped tappable circular image
                  GestureDetector(
                    onTap: pickImage, // tap image to pick
                    child: Hero(
                      tag: 'profile_image_${widget.user.uid}',
                      child: Container(
                        height: 200,
                        width: 200,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary,
                          shape: BoxShape.circle,
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: (!kIsWeb && imagePickedFile != null)
                            ? Image.file(
                                File(imagePickedFile!.path!),
                                fit: BoxFit.cover,
                              )
                            : (kIsWeb && webImage != null)
                            ? Image.memory(webImage!, fit: BoxFit.cover)
                            : CachedNetworkImage(
                                imageUrl:
                                    "${widget.user.profileImageUrl}?v=${DateTime.now().millisecondsSinceEpoch}",
                                // loading..
                                placeholder: (context, url) =>
                                    const CircularProgressIndicator(),
                                // error -> failed to load
                                errorWidget: (context, url, error) => Icon(
                                  Icons.person,
                                  size: 72,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                imageBuilder: (context, imageProvider) => Image(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ),
                    ),
                  ),

                  // bottom-right camera overlay (transparent)
                  Positioned(
                    right: -6,
                    bottom: -6,
                    child: Material(
                      color: Colors.black.withOpacity(0.45),
                      shape: const CircleBorder(),
                      child: IconButton(
                        padding: const EdgeInsets.all(8),
                        iconSize: 18,
                        onPressed: pickImage,
                        icon: const Icon(
                          Icons.camera_alt,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            const SizedBox(height: 10),

            // bio label
            const Text("Bio"),

            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: MyTextField(
                controller: bioTextController,
                hintText: widget.user.bio,
                obscureText: false,
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    bioTextController.dispose();
    super.dispose();
  }
}
