// lib/screens/recommended_sports_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/favorites_service.dart';
import '../services/supabase_service.dart';

class RecommendedSportsPage extends StatefulWidget {
  const RecommendedSportsPage({Key? key}) : super(key: key);

  @override
  State<RecommendedSportsPage> createState() => _RecommendedSportsPageState();
}

class _RecommendedSportsPageState extends State<RecommendedSportsPage> {
  final SupabaseService _supabaseService = SupabaseService();
  List<Map<String, dynamic>> _exercises = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    try {
      final exercises = await _supabaseService.getExercises();
      setState(() {
        _exercises = exercises;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading exercises: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('推荐运动'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.pushNamed(context, '/favorites');
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _exercises.isEmpty
              ? const Center(child: Text('暂无推荐运动'))
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = _exercises[index];
                    return _buildExerciseCard(context, exercise);
                  },
                ),
    );
  }

  Widget _buildExerciseCard(BuildContext context, Map<String, dynamic> exercise) {
    final String exerciseId = exercise['id'];
    final String name = exercise['name'] ?? 'Unknown';
    final String intensity = _getIntensityForExercise(name);
    final int duration = _getDurationForExercise(name);
    final Color cardColor = _getColorForExercise(name);

    return Consumer<FavoritesService>(
      builder: (context, favoritesService, child) {
        final bool isFavorite = favoritesService.isFavorite(exerciseId);

        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              '/breakthrough_mode',
              arguments: name,
            );
          },
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),
                    Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        color: cardColor.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: _getSportIcon(name),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getIntensityColor(intensity).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            intensity,
                            style: TextStyle(
                              color: _getIntensityColor(intensity),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$duration min',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.grey,
                    ),
                    onPressed: () {
                      favoritesService.toggleFavorite(exerciseId);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getIntensityForExercise(String name) {
    switch (name.toLowerCase()) {
      case 'run':
        return 'Low';
      case 'stretch':
        return 'Medium';
      case 'back kick':
        return 'High';
      default:
        return 'Medium';
    }
  }

  int _getDurationForExercise(String name) {
    switch (name.toLowerCase()) {
      case 'run':
        return 10;
      case 'stretch':
        return 15;
      case 'back kick':
        return 12;
      default:
        return 10;
    }
  }

  Color _getColorForExercise(String name) {
    switch (name.toLowerCase()) {
      case 'run':
        return Colors.blue;
      case 'stretch':
        return Colors.purple;
      case 'back kick':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  Widget _getSportIcon(String sportName) {
    IconData iconData;
    
    switch (sportName.toLowerCase()) {
      case 'run':
        iconData = Icons.directions_run;
        break;
      case 'stretch':
        iconData = Icons.self_improvement;
        break;
      case 'back kick':
        iconData = Icons.sports_martial_arts;
        break;
      default:
        iconData = Icons.sports;
    }
    
    return Icon(
      iconData,
      size: 40,
      color: Colors.black87,
    );
  }

  Color _getIntensityColor(String intensity) {
    switch (intensity) {
      case 'Low':
        return Colors.green;
      case 'Medium':
        return Colors.orange;
      case 'High':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}
