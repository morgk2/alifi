class PlacesPrediction {
  final String placeId;
  final String mainText;
  final String secondaryText;
  final String description;

  PlacesPrediction({
    required this.placeId,
    required this.mainText,
    required this.secondaryText,
    required this.description,
  });

  factory PlacesPrediction.fromJson(Map<String, dynamic> json) {
    return PlacesPrediction(
      placeId: json['place_id'] ?? '',
      mainText: json['structured_formatting']?['main_text'] ?? '',
      secondaryText: json['structured_formatting']?['secondary_text'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'place_id': placeId,
      'structured_formatting': {
        'main_text': mainText,
        'secondary_text': secondaryText,
      },
      'description': description,
    };
  }
}

