class Exercise {
  final String id;
  final String name;
  final String videoUrl;
  final String jsonUrl;

  Exercise({
    required this.id,
    required this.name,
    required this.videoUrl,
    required this.jsonUrl,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as String,
      name: json['name'] as String,
      videoUrl: json['video_url'] as String,
      jsonUrl: json['json_url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'video_url': videoUrl,
      'json_url': jsonUrl,
    };
  }
} 