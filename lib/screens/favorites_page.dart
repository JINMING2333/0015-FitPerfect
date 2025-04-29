import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/favorites_service.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
      ),
      body: Consumer<FavoritesService>(
        builder: (context, favoritesService, child) {
          final favorites = favoritesService.favorites.where((id) => _getSportItemById(id) != null);
          
          if (favorites.isEmpty) {
            return const Center(
              child: Text(
                'No favorites yet\nDiscover your favorite sports!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final exerciseId = favorites.elementAt(index);
              final sportItem = _getSportItemById(exerciseId);
              if (sportItem == null) return const SizedBox.shrink();
              return _buildSportCard(context, sportItem, favoritesService);
            },
          );
        },
      ),
    );
  }

  SportItem? _getSportItemById(String id) {
    // 这里硬编码运动信息，实际应用中应该从数据库或服务中获取
    final Map<String, SportItem> items = {
      'run': SportItem(
        name: 'Run',
        intensity: 'Medium',
        duration: 10,
        iconPath: 'assets/images/yoga_icon.png',
        color: Colors.blue.shade100,
        exerciseId: 'run',
      ),
      'stretch': SportItem(
        name: 'Stretch',
        intensity: 'Low',
        duration: 15,
        iconPath: 'assets/images/toning_icon.png',
        color: Colors.purple.shade100,
        exerciseId: 'stretch',
      ),
      'back_kick': SportItem(
        name: 'Back Kick',
        intensity: 'Low',
        duration: 12,
        iconPath: 'assets/images/fat_burn_icon.png',
        color: Colors.red.shade100,
        exerciseId: 'back_kick',
      ),
      'burpee': SportItem(
        name: 'Burpee',
        intensity: 'High',
        duration: 20,
        iconPath: 'assets/images/burpee_icon.png',
        color: Colors.orange.shade100,
        exerciseId: 'burpee',
      ),
      'fat_burning': SportItem(
        name: 'Fat Burning',
        intensity: 'High',
        duration: 25,
        iconPath: 'assets/images/fat_burning_icon.png',
        color: Colors.deepOrange.shade100,
        exerciseId: 'fat_burning',
      ),
      'jumpjump': SportItem(
        name: 'Jump Jump',
        intensity: 'Medium',
        duration: 15,
        iconPath: 'assets/images/jumpjump_icon.png',
        color: Colors.green.shade100,
        exerciseId: 'jumpjump',
      ),
      'knee_lift': SportItem(
        name: 'Knee Lift',
        intensity: 'Medium',
        duration: 12,
        iconPath: 'assets/images/knee_lift_icon.png',
        color: Colors.teal.shade100,
        exerciseId: 'knee_lift',
      ),
      'twist': SportItem(
        name: 'Twist',
        intensity: 'Low',
        duration: 10,
        iconPath: 'assets/images/twist_icon.png',
        color: Colors.indigo.shade100,
        exerciseId: 'twist',
      ),
    };
    
    if (!items.containsKey(id)) {
      debugPrint('Warning: Unknown exercise ID: $id');
      return null;
    }
    return items[id];
  }

  Widget _buildSportCard(BuildContext context, SportItem item, FavoritesService favoritesService) {
    Color intensityColor;
    switch (item.intensity) {
      case 'Low':
        intensityColor = Colors.green;
        break;
      case 'Medium':
        intensityColor = Colors.orange;
        break;
      case 'High':
        intensityColor = Colors.red;
        break;
      default:
        intensityColor = Colors.blue;
    }

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/breakthrough_mode',
          arguments: {
            'exerciseId': item.exerciseId,
            'name': item.name,
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
                    color: item.color,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: _getSportIcon(item.name),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  item.name,
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
                        color: intensityColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        item.intensity,
                        style: TextStyle(
                          color: intensityColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${item.duration} min',
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
                icon: const Icon(
                  Icons.favorite,
                  color: Colors.red,
                ),
                onPressed: () {
                  favoritesService.toggleFavorite(item.exerciseId);
                },
              ),
            ),
          ],
        ),
      ),
    );
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
      case 'back_kick':
        iconData = Icons.sports_martial_arts;
        break;
      case 'burpee':
        iconData = Icons.fitness_center;
        break;
      case 'fat burning':
      case 'fat_burning':
        iconData = Icons.local_fire_department;
        break;
      case 'jump jump':
      case 'jumpjump':
        iconData = Icons.directions_walk;
        break;
      case 'knee lift':
      case 'knee_lift':
        iconData = Icons.accessibility_new;
        break;
      case 'twist':
        iconData = Icons.rotate_right;
        break;
      default:
        debugPrint('Warning: Unknown sport name: $sportName');
        iconData = Icons.sports;
    }
    
    return Icon(
      iconData,
      size: 40,
      color: Colors.black87,
    );
  }
}

class SportItem {
  final String name;
  final String intensity;
  final int duration;
  final String iconPath;
  final Color color;
  final String exerciseId;
  
  SportItem({
    required this.name,
    required this.intensity,
    required this.duration,
    required this.iconPath,
    required this.color,
    required this.exerciseId,
  });
} 