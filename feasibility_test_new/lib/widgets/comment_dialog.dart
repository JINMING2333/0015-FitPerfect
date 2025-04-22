import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/community_service.dart';
import '../services/post_dialog_service.dart';

// 评论对话框组件
class CommentDialog extends StatefulWidget {
  final String postId;
  
  const CommentDialog({
    Key? key,
    required this.postId,
  }) : super(key: key);

  @override
  State<CommentDialog> createState() => _CommentDialogState();
}

class _CommentDialogState extends State<CommentDialog> {
  final TextEditingController _commentController = TextEditingController();
  
  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // 格式化时间显示
  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} ${(difference.inDays / 365).floor() == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} ${(difference.inDays / 30).floor() == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'just now';
    }
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

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context, postDialogService, communityService),
    );
  }

  Widget contentBox(BuildContext context, PostDialogService postDialogService, CommunityService communityService) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Comments',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          const Divider(),
          // 使用 FutureBuilder 和 StreamBuilder 组合来处理评论列表
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: communityService.getPostComments(widget.postId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading comments: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }
                
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No comments yet. Be the first to comment!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  );
                }
                
                final comments = snapshot.data!.docs;
                
                return ListView.separated(
                  padding: const EdgeInsets.only(top: 8),
                  itemCount: comments.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    try {
                      final commentData = comments[index].data() as Map<String, dynamic>;
                      final Timestamp? timestamp = commentData['timestamp'] as Timestamp?;
                      final DateTime commentDate = timestamp?.toDate() ?? DateTime.now();
                      final String timeAgo = _getTimeAgo(commentDate);
                      
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          radius: 16,
                          backgroundImage: commentData['authorPhotoUrl'] != null
                              ? NetworkImage(commentData['authorPhotoUrl'])
                              : null,
                          backgroundColor: Colors.grey[200],
                          child: commentData['authorPhotoUrl'] == null
                              ? Icon(Icons.person, color: Colors.grey[400], size: 16)
                              : null,
                        ),
                        title: Text(
                          commentData['authorName'] ?? 'Anonymous',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              commentData['content'] ?? '',
                              style: const TextStyle(fontSize: 14),
                            ),
                            Text(
                              timeAgo,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        isThreeLine: true,
                        dense: true,
                      );
                    } catch (e) {
                      return ListTile(
                        title: Text('Error displaying comment'),
                        subtitle: Text('$e'),
                        tileColor: Colors.red[50],
                      );
                    }
                  },
                );
              },
            ),
          ),
          const Divider(),
          if (postDialogService.error != null)
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 8),
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
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: 'Add a comment...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: postDialogService.isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                        ),
                      )
                    : const Icon(Icons.send, color: Colors.green),
                onPressed: postDialogService.isLoading
                    ? null
                    : () async {
                        final commentText = _commentController.text.trim();
                        if (commentText.isEmpty) {
                          return;
                        }

                        final success = await postDialogService.addComment(
                          communityService,
                          widget.postId,
                          commentText,
                        );

                        if (success && context.mounted) {
                          _commentController.clear();
                        }
                      },
              ),
            ],
          ),
        ],
      ),
    );
  }
} 