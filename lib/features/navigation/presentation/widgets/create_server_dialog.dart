import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../core/theme.dart';
import '../../../chat/data/chat_repository.dart';
import '../../../../models/server_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class CreateServerDialog extends ConsumerStatefulWidget {
  const CreateServerDialog({super.key});

  @override
  ConsumerState<CreateServerDialog> createState() => _CreateServerDialogState();
}

class _CreateServerDialogState extends ConsumerState<CreateServerDialog> {
  final _nameController = TextEditingController();
  File? _imageFile;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _imageFile = File(image.path));
    }
  }

  Future<void> _createServer() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final user = ref.read(userProvider);
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      String imageUrl = 'https://picsum.photos/seed/${name.hashCode}/100';
      if (_imageFile != null) {
        imageUrl = await ref
            .read(chatRepositoryProvider)
            .uploadImage(_imageFile!);
      }

      final server = AuraServer(
        id: '',
        name: name,
        ownerId: user.uid,
        memberIds: [user.uid],
        imageUrl: imageUrl,
      );

      await ref.read(chatRepositoryProvider).createServer(server);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AuraTheme.backgroundPrimary,
      title: const Text(
        'Customize your server',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Give your new server a personality with a name and an icon.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AuraTheme.textMuted),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AuraTheme.backgroundTertiary,
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!)
                        : null,
                    child: _imageFile == null
                        ? const Icon(
                            Icons.add_a_photo,
                            size: 30,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  if (_imageFile != null)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AuraTheme.brandColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              autofocus: true,
              style: const TextStyle(color: AuraTheme.textNormal),
              decoration: InputDecoration(
                labelText: 'SERVER NAME',
                labelStyle: const TextStyle(
                  color: AuraTheme.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                filled: true,
                fillColor: AuraTheme.backgroundTertiary,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _createServer(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Back', style: TextStyle(color: Colors.white)),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _createServer,
          style: ElevatedButton.styleFrom(
            backgroundColor: AuraTheme.brandColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text('Create', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
