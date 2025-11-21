// lib/features/post/presentation/pages/upload_post_page.dart
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loom/features/auth/domain/entities/app_user.dart';
import 'package:loom/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:loom/features/auth/presentation/components/my_text_field.dart';
import 'package:loom/features/post/domain/entities/post.dart';
import 'package:loom/features/post/presentation/cubits/post_cubit.dart';
import 'package:loom/features/post/presentation/cubits/post_states.dart';
import 'package:loom/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:loom/features/profile/presentation/cubits/profile_states.dart';

class UploadPostPage extends StatefulWidget {
  const UploadPostPage({super.key});
  @override
  State<UploadPostPage> createState() => _UploadPostPageState();
}

class _UploadPostPageState extends State<UploadPostPage> {
  PlatformFile? _pickedFile;
  Uint8List? _webBytes;
  final TextEditingController _caption = TextEditingController();
  AppUser? _me;
  bool _uploadDialogVisible = false;

  @override
  void initState() {
    super.initState();
    _me = context.read<AuthCubit>().currentUser;
    if (_me?.uid != null)
      context.read<ProfileCubit>().fetchProfileUser(_me!.uid);
  }

  @override
  void dispose() {
    _caption.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final res = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: kIsWeb,
      );
      if (res == null || res.files.isEmpty) return;
      setState(() {
        _pickedFile = res.files.first;
        _webBytes = kIsWeb ? _pickedFile!.bytes : null;
      });
    } catch (e) {
      debugPrint('pick error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to pick image')));
    }
  }

  bool get _canUpload =>
      (_pickedFile != null) || _caption.text.trim().isNotEmpty;

  // show a full-screen modal upload dialog (covers whole device)
  void _showUploadingDialog() {
    if (!mounted || _uploadDialogVisible) return;
    _uploadDialogVisible = true;

    // Use rootNavigator so dialog is on top of the page route stack reliably.
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'uploading',
      barrierColor: Colors.black.withOpacity(0.45),
      // IMPORTANT: Use root navigator so pop with rootNavigator: true closes this route
      // and does not interfere with page navigation.
      pageBuilder: (_, __, ___) {
        return Center(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 12,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 22.0,
                vertical: 16.0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 14),
                  Text(
                    'Uploading...',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      useRootNavigator: true,
    );
  }

  // hide the dialog if it is visible
  void _hideUploadingDialog() {
    if (!_uploadDialogVisible) return;
    _uploadDialogVisible = false;
    try {
      // pop the dialog route specifically using rootNavigator
      if (mounted && Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    } catch (e) {
      // ignore
    }
  }

  // upload and ONLY POP THE PAGE ON SUCCESS (after dialog closed)
  Future<void> _upload() async {
    if (!_canUpload) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select an image or write a caption')),
      );
      return;
    }

    // close keyboard so dialog sits centered
    FocusScope.of(context).unfocus();

    setState(() {}); // no local uploading flag; UI driven by Bloc
    _showUploadingDialog();

    final post = Post(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: _me?.uid ?? 'unknown',
      userName: (_me?.name != null && _me!.name.trim().isNotEmpty)
          ? _me!.name
          : (_me?.email ?? 'Unknown'),
      text: _caption.text.trim(),
      imageUrl: '',
      timestamp: DateTime.now(),
      likes: [],
      comments: [],
    );

    try {
      final postCubit = context.read<PostCubit>();
      if (kIsWeb) {
        await postCubit.createPost(post, imageBytes: _pickedFile?.bytes);
      } else {
        await postCubit.createPost(post, imagePath: _pickedFile?.path);
      }

      // success path: hide dialog, clear fields, show success message
      _hideUploadingDialog();

      if (!mounted) return;
      setState(() {
        _pickedFile = null;
        _webBytes = null;
        _caption.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post uploaded successfully!')),
      );
    } catch (e) {
      debugPrint('upload err: $e');
      _hideUploadingDialog();
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return BlocConsumer<PostCubit, PostState>(
      listener: (c, s) {
        // NOTE: listener no longer pops the page. it only shows/hides dialog + shows errors.
        if (s is PostsUploading) {
          if (mounted) _showUploadingDialog();
        } else if (s is PostsLoaded) {
          _hideUploadingDialog();
          // do not call Navigator.pop() here — _upload() already handles the page pop
        } else if (s is PostsError) {
          _hideUploadingDialog();
          if (mounted)
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(s.message)));
        }
      },
      builder: (c, s) {
        final uploading = s is PostsUploading || s is PostsLoading;

        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: Text(
              'Create Post',
              style: TextStyle(color: primary, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            iconTheme: IconThemeData(color: primary),
            elevation: 0,
            actions: [
              IconButton(
                onPressed: (_canUpload && !uploading) ? _upload : null,
                icon: Icon(
                  Icons.upload,
                  color: (_canUpload && !uploading) ? primary : null,
                ),
              ),
            ],
          ),

          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom:
                    16 +
                    MediaQuery.of(context).viewInsets.bottom +
                    MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  BlocBuilder<ProfileCubit, ProfileState>(
                    builder: (ctx, ps) {
                      String display = _me?.name ?? (_me?.email ?? '');
                      String? avatarUrl;
                      if (ps is ProfileLoaded &&
                          _me != null &&
                          ps.profileUser.uid == _me!.uid) {
                        display = ps.profileUser.name.isNotEmpty
                            ? ps.profileUser.name
                            : display;
                        avatarUrl = ps.profileUser.profileImageUrl.isNotEmpty
                            ? ps.profileUser.profileImageUrl
                            : null;
                      }
                      return Row(
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.surface,
                                child: avatarUrl != null
                                    ? ClipOval(
                                        child: CachedNetworkImage(
                                          imageUrl: avatarUrl,
                                          placeholder: (_, __) =>
                                              const SizedBox(
                                                width: 40,
                                                height: 40,
                                                child: Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                      ),
                                                ),
                                              ),
                                          errorWidget: (_, __, ___) =>
                                              const Icon(Icons.person),
                                          width: 40,
                                          height: 40,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : const Icon(Icons.person),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                display,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // square preview
                  GestureDetector(
                    onTap: _pickImage,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          color: Theme.of(
                            context,
                          ).colorScheme.onBackground.withOpacity(0.02),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: _pickedFile != null
                                    ? (kIsWeb && _webBytes != null
                                          ? Image.memory(
                                              _webBytes!,
                                              fit: BoxFit.cover,
                                            )
                                          : (_pickedFile?.path != null
                                                ? Image.file(
                                                    File(_pickedFile!.path!),
                                                    fit: BoxFit.cover,
                                                  )
                                                : const SizedBox.shrink()))
                                    : Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.photo,
                                              size: 44,
                                              color: primary,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Tap to add a photo',
                                              style: TextStyle(
                                                color: primary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                              ),

                              // camera button bottom-right
                              Positioned(
                                right: 12,
                                bottom: 12,
                                child: Material(
                                  elevation: 4,
                                  shape: const CircleBorder(),
                                  color: primary,
                                  child: InkWell(
                                    onTap: _pickImage,
                                    customBorder: const CircleBorder(),
                                    child: const Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              if (uploading)
                                Positioned.fill(
                                  child: Container(
                                    color: Colors.black.withOpacity(0.18),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Choose Image'),
                  ),
                  const SizedBox(height: 12),

                  MyTextField(
                    controller: _caption,
                    hintText: 'Write a caption...',
                    obscureText: false,
                  ),
                  const SizedBox(height: 12),

                  ElevatedButton.icon(
                    onPressed:
                        (_canUpload &&
                            !(s is PostsUploading || s is PostsLoading))
                        ? _upload
                        : null,
                    icon: s is PostsUploading || s is PostsLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.cloud_upload),
                    label: Text(
                      (s is PostsUploading || s is PostsLoading)
                          ? 'Uploading...'
                          : 'Upload Post',
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
