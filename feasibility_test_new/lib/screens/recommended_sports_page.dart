// lib/screens/recommended_sports_page.dart
import 'package:flutter/material.dart';
import 'breakthrough_mode_page.dart';

class RecommendedSportsPage extends StatefulWidget {
  const RecommendedSportsPage({Key? key}) : super(key: key);

  @override
  State<RecommendedSportsPage> createState() => _RecommendedSportsPageState();
}

class _RecommendedSportsPageState extends State<RecommendedSportsPage> {
  final List<SportItem> _sportItems = [
    SportItem(
      name: 'Yoga',
      intensity: 'Low',
      duration: 10,
      iconPath: 'assets/images/yoga_icon.png',
      color: Colors.blue.shade100,
    ),
    SportItem(
      name: 'Tai Chi',
      intensity: 'Medium',
      duration: 10,
      iconPath: 'assets/images/tai_chi_icon.png',
      color: Colors.green.shade100,
    ),
    SportItem(
      name: 'Pilates',
      intensity: 'Medium',
      duration: 15,
      iconPath: 'assets/images/toning_icon.png',
      color: Colors.purple.shade100,
    ),
    SportItem(
      name: 'Stretch',
      intensity: 'Low',
      duration: 10,
      iconPath: 'assets/images/cardio_icon.png',
      color: Colors.orange.shade100,
    ),
    SportItem(
      name: 'Fat Burn',
      intensity: 'High',
      duration: 12,
      iconPath: 'assets/images/fat_burn_icon.png',
      color: Colors.red.shade100,
    ),
    SportItem(
      name: 'Strength',
      intensity: 'High',
      duration: 10,
      iconPath: 'assets/images/strength_icon.png',
      color: Colors.amber.shade100,
    ),
  ];

  final Set<int> _favorites = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hey Sweetie!',
                    style: TextStyle(
                      color: Colors.purple,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Let\'s start sweating ~',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _sportItems.length,
                  itemBuilder: (context, index) {
                    return _buildSportCard(index);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSportCard(int index) {
    final item = _sportItems[index];
    final bool isFavorite = _favorites.contains(index);
    
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
          arguments: item.name,
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
                    // Use Icon with a placeholder until actual icons are available
                    child: _getSportIcon(item.name),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    if (isFavorite) {
                      _favorites.remove(index);
                    } else {
                      _favorites.add(index);
                    }
                  });
                },
                child: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.grey,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getSportIcon(String sportName) {
    // This would ideally use the actual image assets
    // For now, using placeholder icons based on sport type
    IconData iconData;
    
    switch (sportName) {
      case 'Yoga':
        iconData = Icons.self_improvement;
        break;
      case 'Tai Chi':
        iconData = Icons.sports_martial_arts;
        break;
      case 'Toning':
        iconData = Icons.fitness_center;
        break;
      case 'Cardio':
        iconData = Icons.directions_run;
        break;
      case 'Fat Burn':
        iconData = Icons.local_fire_department;
        break;
      case 'Strength':
        iconData = Icons.fitness_center;
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
}

class SportItem {
  final String name;
  final String intensity;
  final int duration;
  final String iconPath;
  final Color color;
  
  SportItem({
    required this.name,
    required this.intensity,
    required this.duration,
    required this.iconPath,
    required this.color,
  });
}
