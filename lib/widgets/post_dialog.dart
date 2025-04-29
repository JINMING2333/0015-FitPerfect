import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/community_service.dart';
import '../services/post_dialog_service.dart';

// 帖子创建对话框组件
class CreatePostDialog extends StatefulWidget {
  const CreatePostDialog({Key? key}) : super(key: key);

  @override
  State<CreatePostDialog> createState() => _CreatePostDialogState();
}

class _CreatePostDialogState extends State<CreatePostDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  
  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final postDialogService = Provider.of<PostDialogService>(context);
    final communityService = Provider.of<CommunityService>(context, listen: false);
    
    // 清除之前的状态
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (postDialogService.isSuccess || postDialogService.error != null) {
        postDialogService.reset();
      }
    });

    return AlertDialog(
      title: const Text('Create New Post'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Post title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.green, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contentController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Share your thoughts...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.green, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (postDialogService.error != null)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  postDialogService.error!,
                  style: TextStyle(color: Colors.red.shade700),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: postDialogService.isLoading
              ? null
              : () async {
                  if (_contentController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter some content'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return;
                  }

                  final success = await postDialogService.createPost(
                    communityService, 
                    _contentController.text.trim(),
                    title: _titleController.text.trim(),
                  );
                  
                  if (success && context.mounted) {
                    Navigator.of(context).pop(true);
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
          ),
          child: postDialogService.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2,
                  ),
                )
              : const Text('Post'),
        ),
      ],
    );
  }
} 