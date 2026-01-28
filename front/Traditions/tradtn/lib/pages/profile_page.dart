import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/profile.dart';
import '../services/api_service.dart';
import '../theme/app_spacing.dart';
import '../theme/theme_controller.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/app_icon_button.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/app_text_field.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.themeController});

  final ThemeController themeController;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _usernameController = TextEditingController();

  UserProfile? _profile;
  bool _loading = true;
  String? _loadError;

  bool _editingName = false;
  bool _savingName = false;
  String? _nameError;

  File? _pendingAvatar;
  bool _uploadingAvatar = false;
  String? _avatarError;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    final profile = await ApiService.fetchProfile();
    if (!mounted) return;

    if (profile == null) {
      setState(() {
        _loading = false;
        _loadError = 'Failed to load profile';
      });
      return;
    }

    _usernameController.text = profile.username;
    setState(() {
      _profile = profile;
      _loading = false;
    });
  }

  String? _validateUsername(String value) {
    final v = value.trim();
    if (v.isEmpty) return 'Username is required';
    if (!RegExp(r'^[a-zA-Z0-9_]{3,20}$').hasMatch(v)) {
      return '3-20 chars: a-z, 0-9, _';
    }
    return null;
  }

  Future<void> _saveUsername() async {
    final error = _validateUsername(_usernameController.text);
    if (error != null) {
      setState(() => _nameError = error);
      return;
    }

    setState(() {
      _savingName = true;
      _nameError = null;
    });

    final res = await ApiService.updateProfile(
      username: _usernameController.text.trim(),
    );

    if (!mounted) return;

    if (res != null) {
      setState(() {
        _savingName = false;
        _nameError = res;
      });
      return;
    }

    setState(() {
      _savingName = false;
      _editingName = false;
      _profile = _profile?.copyWith(username: _usernameController.text.trim());
    });
  }

  Future<void> _pickAvatar(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 512,
    );
    if (picked == null) return;
    setState(() {
      _pendingAvatar = File(picked.path);
      _avatarError = null;
    });
  }

  Future<void> _uploadAvatar() async {
    final file = _pendingAvatar;
    if (file == null) return;

    setState(() {
      _uploadingAvatar = true;
      _avatarError = null;
    });

    final res = await ApiService.uploadAvatar(file);
    if (!mounted) return;

    if (res != null && res.startsWith('http')) {
      setState(() {
        _uploadingAvatar = false;
        _pendingAvatar = null;
        _profile = _profile?.copyWith(avatarUrl: res);
      });
      return;
    }

    setState(() {
      _uploadingAvatar = false;
      _avatarError = res ?? 'Upload failed';
    });
  }

  void _cancelAvatar() {
    setState(() {
      _pendingAvatar = null;
      _avatarError = null;
    });
  }

  void _openAvatarSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AppCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Take photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickAvatar(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickAvatar(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;

    return AppScaffold(
      safeArea: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppIconButton(
              icon: Icons.arrow_back_rounded,
              onPressed: () => Navigator.pop(context),
              tooltip: 'Back',
            ),
            const SizedBox(height: AppSpacing.lg),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_loadError != null)
              Text(
                _loadError!,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.error),
              )
            else
              _buildProfileContent(context, isLight),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, bool isLight) {
    final theme = Theme.of(context);
    final profile = _profile!;
    final initials = profile.username.isNotEmpty
        ? profile.username.substring(0, 1).toUpperCase()
        : 'U';

    final ImageProvider? avatarImage = _pendingAvatar != null
        ? FileImage(_pendingAvatar!)
        : (profile.avatarUrl.isNotEmpty ? NetworkImage(profile.avatarUrl) : null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: _openAvatarSheet,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor:
                        theme.colorScheme.primary.withOpacity(0.2),
                    backgroundImage: avatarImage,
                    child: _pendingAvatar == null && profile.avatarUrl.isEmpty
                        ? Text(
                            initials,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: theme.colorScheme.primary,
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(profile.email, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    profile.role,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (_pendingAvatar != null) ...[
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'New photo selected',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Save photo',
                        loading: _uploadingAvatar,
                        onPressed: _uploadingAvatar ? null : _uploadAvatar,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    AppButton(
                      label: 'Cancel',
                      onPressed: _cancelAvatar,
                      variant: AppButtonVariant.ghost,
                      fullWidth: false,
                    ),
                  ],
                ),
                if (_avatarError != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _avatarError!,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: theme.colorScheme.error),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Profile', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(
                controller: _usernameController,
                label: 'Username',
                hintText: 'user',
                enabled: _editingName && !_savingName,
                errorText: _nameError,
                onChanged: (_) {
                  if (_editingName) {
                    setState(() => _nameError = null);
                  }
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  if (_editingName) ...[
                    Expanded(
                      child: AppButton(
                        label: 'Save',
                        loading: _savingName,
                        onPressed: _savingName ? null : _saveUsername,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    AppButton(
                      label: 'Cancel',
                      onPressed: () {
                        setState(() {
                          _editingName = false;
                          _nameError = null;
                          _usernameController.text = profile.username;
                        });
                      },
                      variant: AppButtonVariant.ghost,
                      fullWidth: false,
                    ),
                  ] else
                    AppButton(
                      label: 'Edit username',
                      onPressed: () {
                        setState(() {
                          _editingName = true;
                          _nameError = null;
                        });
                      },
                      variant: AppButtonVariant.secondary,
                      fullWidth: false,
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Appearance', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Light theme'),
                subtitle: Text(
                  isLight ? 'Light mode enabled' : 'Dark mode enabled',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                value: isLight,
                onChanged: (value) {
                  widget.themeController
                      .setMode(value ? ThemeMode.light : ThemeMode.dark);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

extension on UserProfile {
  UserProfile copyWith({
    String? email,
    String? role,
    String? username,
    String? avatarUrl,
    String? themePreference,
  }) {
    return UserProfile(
      email: email ?? this.email,
      role: role ?? this.role,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      themePreference: themePreference ?? this.themePreference,
    );
  }
}
