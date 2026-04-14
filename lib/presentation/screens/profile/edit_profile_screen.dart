import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:parent_school_app/core/localization/l10n_extension.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../providers/user_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  bool _notificationsEnabled = true;
  String? _avatarPath;

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProvider).user;
    _fullNameController = TextEditingController(text: user?.fullName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _notificationsEnabled = user?.notificationsEnabled ?? true;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1200,
    );

    if (file == null || !mounted) return;

    setState(() {
      _avatarPath = file.path;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(userProvider.notifier);
    notifier.clearError();

    await notifier.updateProfile(
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      notificationsEnabled: _notificationsEnabled,
    );

    var state = ref.read(userProvider);
    if (state.error != null) {
      if (!mounted) return;
      AppSnackBar.show(context, state.error!, type: AppSnackBarType.error);
      return;
    }

    if (_avatarPath != null && _avatarPath!.isNotEmpty) {
      await notifier.uploadAvatar(_avatarPath!);
      state = ref.read(userProvider);
      if (state.error != null) {
        if (!mounted) return;
        AppSnackBar.show(context, state.error!, type: AppSnackBarType.error);
        return;
      }
    }

    if (!mounted) return;
    AppSnackBar.show(
      context,
      context.l10n.profileUpdatedSuccess,
      type: AppSnackBarType.success,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final userState = ref.watch(userProvider);
    final user = userState.user;
    final isLoading = userState.isLoading;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    ImageProvider<Object>? avatarImage;
    if (_avatarPath != null) {
      avatarImage = FileImage(File(_avatarPath!));
    } else if (user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty) {
      avatarImage = NetworkImage(user.avatarUrl!);
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.editProfileTitle),
        actions: [
          TextButton(
            onPressed: isLoading ? null : _submit,
            child: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    l10n.saveAction,
                    style: TextStyle(
                      color:
                          theme.appBarTheme.foregroundColor ??
                          colorScheme.onPrimary,
                    ),
                  ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: theme.cardColor,
                        backgroundImage: avatarImage,
                        child: avatarImage == null
                            ? Icon(
                                Icons.person_rounded,
                                size: 42,
                                color: colorScheme.primary,
                              )
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: isLoading ? null : _pickAvatar,
                        icon: const Icon(Icons.photo_camera_outlined),
                        label: Text(l10n.changeAvatarAction),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.basicInfoTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _fullNameController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: l10n.fullNameLabel,
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.fullNameRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: l10n.phoneNumberLabel,
                    prefixIcon: const Icon(Icons.phone_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.phoneRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: l10n.emailSection,
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colorScheme.outline),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.notificationsToggleTitle,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.notificationsToggleSubtitle,
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch.adaptive(
                        value: _notificationsEnabled,
                        onChanged: isLoading
                            ? null
                            : (value) {
                                setState(() {
                                  _notificationsEnabled = value;
                                });
                              },
                      ),
                    ],
                  ),
                ),
                if (userState.error != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    userState.error!,
                    style: TextStyle(
                      color: colorScheme.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submit,
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.saveAction),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
