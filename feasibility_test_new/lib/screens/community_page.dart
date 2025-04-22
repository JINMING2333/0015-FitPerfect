// lib/screens/community_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../services/community_service.dart';
import '../services/auth_service.dart';
import '../services/post_dialog_service.dart';
import '../widgets/post_dialog.dart';
import '../widgets/comment_dialog.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({Key? key}) : super(key: key);

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final communityService = Provider.of<CommunityService>(context);
    final authService = Provider.of<AuthService>(context);
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Community',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.green,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.green,
          tabs: const [
            Tab(
              icon: Icon(Icons.chat_bubble_outline),
              text: 'Discussion',
            ),
            Tab(
              icon: Icon(Icons.leaderboard_outlined),
              text: 'Leaderboard',
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black87),
            onPressed: () {
              // 搜索功能
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCommunicationTab(communityService, authService),
          _buildLeaderboardTab(),
        ],
      ),
      floatingActionButton: authService.isLoggedIn ? FloatingActionButton(
        onPressed: () {
          _showCreatePostDialog(context);
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ) : null,
    );
  }

  void _showCreatePostDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return const CreatePostDialog();
      },
    ).then((result) {
      if (result == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post created successfully'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  void _showCommentsDialog(BuildContext context, String postId) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return CommentDialog(postId: postId);
      },
    );
  }

  Widget _buildCommunicationTab(CommunityService communityService, AuthService authService) {
    if (!authService.isLoggedIn) {
      return _buildLoginPrompt();
    }
    
    return SafeArea(
      child: Column(
        children: [
          _buildRecommendSection(),
          Expanded(
            child: _buildFirestorePosts(communityService),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'You need to log in to view and post in the community',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(200, 45),
              ),
              child: const Text('Log In'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/register');
              },
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendSection() {
    final communityService = Provider.of<CommunityService>(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'Popular Posts',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(
            height: 200,
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: communityService.getTopLikedPosts(3),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading popular posts',
                      style: TextStyle(color: Colors.red[400]),
                    ),
                  );
                }
                
                final posts = snapshot.data ?? [];
                
                if (posts.isEmpty) {
                  return const Center(
                    child: Text(
                      'No posts yet. Be the first to share!',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }
                
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return _buildPopularPostCard(post);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularPostCard(Map<String, dynamic> post) {
    final String postId = post['id'] ?? '';
    String title = post['title'] ?? 'Untitled';
    int likes = post['likes'] ?? 0;
    String authorName = post['authorName'] ?? 'Anonymous';
    
    // Truncate title if too long
    if (title.length > 20) {
      title = '${title.substring(0, 20)}...';
    }
    
    return GestureDetector(
      onTap: () {
        _showPostDetailDialog(context, postId);
      },
      child: Container(
        width: 150,
        height: 160,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Title and likes at top
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.favorite, color: Colors.red.shade400, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '$likes',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            // Author information at bottom
            Positioned(
              left: 12,
              bottom: 12,
              child: Text(
                'By $authorName',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPostDetailDialog(BuildContext context, String postId) {
    final communityService = Provider.of<CommunityService>(context, listen: false);
    
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('community_posts').doc(postId).get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              
              if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
                return const SizedBox(
                  height: 200,
                  child: Center(child: Text('Error loading post')),
                );
              }
              
              final postData = snapshot.data!.data() as Map<String, dynamic>;
              final String title = postData['title'] ?? 'Untitled';
              final String content = postData['content'] ?? '';
              final String authorName = postData['authorName'] ?? 'Anonymous';
              final Timestamp? timestamp = postData['timestamp'] as Timestamp?;
              final DateTime postDate = timestamp?.toDate() ?? DateTime.now();
              final String timeAgo = _getTimeAgo(postDate);
              
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Post header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundImage: postData['authorPhotoUrl'] != null
                                    ? NetworkImage(postData['authorPhotoUrl'])
                                    : null,
                                backgroundColor: Colors.grey[200],
                                child: postData['authorPhotoUrl'] == null
                                    ? Icon(Icons.person, color: Colors.grey[400], size: 16)
                                    : null,
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    authorName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
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
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Post content
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        content,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    
                    // Divider
                    Divider(color: Colors.grey[300]),
                    
                    // Comment section
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Comments',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 300,
                            child: CommentSection(postId: postId),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
  
  Widget CommentSection(
    {required String postId}) {
    final communityService = Provider.of<CommunityService>(context, listen: false);
    final TextEditingController commentController = TextEditingController();
    
    return Column(
      children: [
        // Comment input
        if (communityService.isLoggedIn)
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: commentController,
                  decoration: InputDecoration(
                    hintText: 'Write a comment...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send),
                color: Colors.green,
                onPressed: () async {
                  if (commentController.text.trim().isNotEmpty) {
                    await communityService.addComment(
                      postId: postId,
                      content: commentController.text.trim(),
                    );
                    commentController.clear();
                  }
                },
              ),
            ],
          ),
        const SizedBox(height: 12),
        
        // Comments list
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: communityService.getPostComments(postId),
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
                itemCount: comments.length,
                separatorBuilder: (_, __) => Divider(color: Colors.grey[200]),
                itemBuilder: (context, index) {
                  final comment = comments[index].data() as Map<String, dynamic>;
                  final Timestamp? timestamp = comment['timestamp'] as Timestamp?;
                  final DateTime commentDate = timestamp?.toDate() ?? DateTime.now();
                  final String timeAgo = _getTimeAgo(commentDate);
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundImage: comment['authorPhotoUrl'] != null
                              ? NetworkImage(comment['authorPhotoUrl'])
                              : null,
                          backgroundColor: Colors.grey[200],
                          child: comment['authorPhotoUrl'] == null
                              ? Icon(Icons.person, color: Colors.grey[400], size: 14)
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    comment['authorName'] ?? 'Anonymous',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    timeAgo,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                comment['content'] ?? '',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFirestorePosts(CommunityService communityService) {
    return StreamBuilder<QuerySnapshot>(
      stream: communityService.getCommunityPosts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading posts: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }
        
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'No posts yet. Be the first to share something!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          );
        }
        
        // Get all posts
        List<DocumentSnapshot> posts = snapshot.data!.docs;
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          shrinkWrap: true,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            try {
              final postData = posts[index].data() as Map<String, dynamic>;
              final String postId = posts[index].id;
              return _buildPostCard(postId, postData, communityService);
            } catch (e) {
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('Error displaying post: $e'),
              );
            }
          },
        );
      },
    );
  }

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

  Widget _buildPostCard(String postId, Map<String, dynamic> post, CommunityService communityService) {
    final bool isCurrentUserAuthor = communityService.userId == post['authorId'];
    final Timestamp? timestamp = post['timestamp'] as Timestamp?;
    final DateTime postDate = timestamp?.toDate() ?? DateTime.now();
    final String timeAgo = _getTimeAgo(postDate);
    final List<dynamic> likedBy = post['likedBy'] ?? [];
    final bool userLiked = likedBy.contains(communityService.userId);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: post['authorPhotoUrl'] != null
                      ? NetworkImage(post['authorPhotoUrl'])
                      : null,
                  backgroundColor: Colors.grey[200],
                  child: post['authorPhotoUrl'] == null
                      ? Icon(Icons.person, color: Colors.grey[400])
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post['authorName'] ?? 'Anonymous',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
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
                ),
                if (isCurrentUserAuthor)
                  IconButton(
                    icon: const Icon(Icons.more_horiz),
                    onPressed: () {
                      _showPostOptions(context, postId, communityService);
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),
          
          // Post content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Post title
                if (post['title'] != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      post['title'] ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                // Post content
                Text(
                  post['content'] ?? '',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          
          // Post image (if any)
          if (post['imageUrl'] != null && post['imageUrl'].toString().isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Image.network(
                post['imageUrl'],
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: Icon(Icons.image, color: Colors.grey[400], size: 40),
                ),
              ),
            ),
          
          // Interaction buttons
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _buildInteractionButton(
                  userLiked ? Icons.favorite : Icons.favorite_border,
                  '${post['likes'] ?? 0}',
                  userLiked ? Colors.red : Colors.grey[600],
                  () => communityService.likePost(postId),
                ),
                const SizedBox(width: 16),
                _buildInteractionButton(
                  Icons.chat_bubble_outline,
                  '${post['comments'] ?? 0}',
                  Colors.grey[600],
                  () => _showCommentsDialog(context, postId),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionButton(IconData icon, String label, Color? color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showPostOptions(BuildContext context, String postId, CommunityService communityService) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Post Options'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Post'),
              onTap: () async {
                // 先关闭当前对话框，避免多层对话框问题
                Navigator.pop(dialogContext);
                
                // 使用单独的上下文显示确认对话框
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (confirmContext) => AlertDialog(
                    title: const Text('Confirm Deletion'),
                    content: const Text('Are you sure you want to delete this post? This action cannot be undone.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(confirmContext, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(confirmContext, true),
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                ) ?? false; // 默认为 false，如果对话框被取消
                
                // 检查组件是否仍然挂载
                if (!mounted) return;
                
                if (confirmed) {
                  try {
                    final success = await communityService.deletePost(postId);
                    
                    // 再次检查组件是否仍然挂载
                    if (!mounted) return;
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success ? 'Post deleted successfully' : 'Failed to delete post'
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  } catch (e) {
                    // 处理异常
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardTab() {
    // Mock leaderboard data
    List<Map<String, dynamic>> leaderboardData = [
      {
        'rank': 1,
        'username': 'Runner Pro',
        'avatar': 'assets/images/avatar3.jpg',
        'exerciseMinutes': 1250,
        'exerciseDays': 28,
      },
      {
        'rank': 2,
        'username': 'Fitness Expert',
        'avatar': 'assets/images/avatar1.jpg',
        'exerciseMinutes': 1120,
        'exerciseDays': 26,
      },
      {
        'rank': 3,
        'username': 'Yoga Lover',
        'avatar': 'assets/images/avatar2.jpg',
        'exerciseMinutes': 960,
        'exerciseDays': 24,
      },
      {
        'rank': 4,
        'username': 'Strength Trainer',
        'avatar': 'assets/images/avatar4.jpg',
        'exerciseMinutes': 820,
        'exerciseDays': 20,
      },
      {
        'rank': 5,
        'username': 'Dance Enthusiast',
        'avatar': 'assets/images/avatar5.jpg',
        'exerciseMinutes': 780,
        'exerciseDays': 22,
      },
      {
        'rank': 6,
        'username': 'Cycling Pro',
        'avatar': 'assets/images/avatar6.jpg',
        'exerciseMinutes': 750,
        'exerciseDays': 18,
      },
      {
        'rank': 7,
        'username': 'Me',
        'avatar': 'assets/images/avatar_me.jpg',
        'exerciseMinutes': 680,
        'exerciseDays': 19,
        'isMe': true,
      },
    ];

    return Column(
      children: [
        // Leaderboard top
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade300, Colors.green.shade100],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              const Text(
                'Monthly Exercise Leaderboard',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'End date: ${DateFormat('yyyy/MM').format(DateTime.now())}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 24),
              _buildTopThreeRow(leaderboardData.take(3).toList()),
            ],
          ),
        ),
        
        // Leaderboard list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(0),
            itemCount: leaderboardData.length,
            itemBuilder: (context, index) {
              final item = leaderboardData[index];
              // Skip top 3 as they're shown at the top
              if (index < 3) return const SizedBox.shrink();
              
              return _buildLeaderboardItem(item);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTopThreeRow(List<Map<String, dynamic>> topThree) {
    // Ensure we have 3 data entries
    while (topThree.length < 3) {
      topThree.add({
        'rank': topThree.length + 1,
        'username': 'Position Open',
        'avatar': null,
        'exerciseMinutes': 0,
        'exerciseDays': 0,
      });
    }

    // Order: 2nd on left, 1st in middle, 3rd on right
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 2nd place
        _buildTopRankItem(topThree[1], 2, 70, Colors.blue.shade300),
        const SizedBox(width: 8),
        // 1st place
        _buildTopRankItem(topThree[0], 1, 90, Colors.amber.shade300),
        const SizedBox(width: 8),
        // 3rd place
        _buildTopRankItem(topThree[2], 3, 60, Colors.green.shade300),
      ],
    );
  }

  Widget _buildTopRankItem(Map<String, dynamic> data, int rank, double size, Color color) {
    return Column(
      children: [
        // Rank label
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'NO.${data['rank']}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Avatar
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 3),
                color: Colors.white,
              ),
              child: ClipOval(
                child: data['avatar'] != null
                    ? Image.asset(
                        data['avatar'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.person,
                          color: Colors.grey[400],
                          size: size * 0.5,
                        ),
                      )
                    : Icon(
                        Icons.person,
                        color: Colors.grey[400],
                        size: size * 0.5,
                      ),
              ),
            ),
            if (data['isMe'] == true)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Text(
                    'Me',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        // Username
        Text(
          data['username'],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        // Exercise duration
        Text(
          '${data['exerciseMinutes']} minutes',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardItem(Map<String, dynamic> item) {
    final bool isMe = item['isMe'] == true;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isMe ? Colors.green.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
        border: isMe ? Border.all(color: Colors.green.shade300) : null,
      ),
      child: Row(
        children: [
          // Rank
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isMe ? Colors.green : Colors.grey.shade200,
            ),
            child: Center(
              child: Text(
                '${item['rank']}',
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundImage: item['avatar'] != null
                ? AssetImage(item['avatar'])
                : null,
            backgroundColor: Colors.grey[200],
            child: item['avatar'] == null
                ? Icon(Icons.person, color: Colors.grey[400])
                : null,
          ),
          const SizedBox(width: 12),
          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      item['username'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    if (isMe)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Me',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Exercised ${item['exerciseDays']} days this month, total ${item['exerciseMinutes']} minutes',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Medal icon (only for top 3)
          if (item['rank'] <= 3)
            Icon(
              Icons.emoji_events,
              color: item['rank'] == 1
                  ? Colors.amber
                  : item['rank'] == 2
                      ? Colors.blueGrey
                      : Colors.brown,
              size: 24,
            ),
        ],
      ),
    );
  }
}

