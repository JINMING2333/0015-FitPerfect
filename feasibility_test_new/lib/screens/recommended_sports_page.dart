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
        title: const Text('Recommended Sports'),
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
              ? const Center(child: Text('No recommended sports'))
              : RefreshIndicator(
                  onRefresh: _loadExercises,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    physics: const AlwaysScrollableScrollPhysics(),
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
              arguments: {
                'exerciseId': exerciseId,
                'name': name,
              },
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
      case 'back_kick':
        return 'Low';
      case 'stretch':
        return 'Low';
      case 'twist':
        return 'Low';
      case 'burpee':
        return 'High';
      case 'fat_burning':
        return 'High';
      case 'run':
        return 'Medium';
      case 'jumpjump':
        return 'Medium';
      case 'knee_lift':
        return 'Medium';
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
      case 'back_kick':
        return 12;
      case 'burpee':
        return 20;
      case 'fat_burning':
        return 25;
      case 'jumpjump':
        return 15;
      case 'knee_lift':
        return 12;
      case 'twist':
        return 10;
      default:
        return 10;
    }
  }

  Color _getColorForExercise(String name) {
    switch (name.toLowerCase()) {
      case 'run':
        return Colors.blue.shade100;
      case 'stretch':
        return Colors.purple.shade100;
      case 'back_kick':
        return Colors.red.shade100;
      case 'burpee':
        return Colors.orange.shade100;
      case 'fat_burning':
        return Colors.deepOrange.shade100;
      case 'jumpjump':
        return Colors.green.shade100;
      case 'knee_lift':
        return Colors.teal.shade100;
      case 'twist':
        return Colors.indigo.shade100;
      default:
        return Colors.blue.shade100;
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
      case 'back_kick':
        iconData = Icons.sports_martial_arts;
        break;
      case 'burpee':
        iconData = Icons.fitness_center;
        break;
      case 'fat_burning':
        iconData = Icons.local_fire_department;
        break;
      case 'jumpjump':
        iconData = Icons.directions_walk;
        break;
      case 'knee_lift':
        iconData = Icons.accessibility_new;
        break;
      case 'twist':
        iconData = Icons.rotate_right;
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
