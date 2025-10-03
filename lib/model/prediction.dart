class PlacesAutocompleteResponse {
  final List<Prediction> predictions;

  PlacesAutocompleteResponse({this.predictions = const []});

  factory PlacesAutocompleteResponse.fromJson(Map<String, dynamic> json) {
    if (json['suggestions'] != null) {
      return PlacesAutocompleteResponse(
        predictions: (json['suggestions'] as List)
            .map((v) => Prediction.fromJson(v['placePrediction']))
            .toList(),
      );
    }
    return PlacesAutocompleteResponse();
  }
}

class Prediction {
  final String? description;
  final String? placeId;
  final StructuredFormatting? structuredFormatting;
  String? lat;
  String? lng;

  Prediction({
    this.description,
    this.placeId,
    this.structuredFormatting,
    this.lat,
    this.lng,
  });

  factory Prediction.fromJson(Map<String, dynamic> json) {
    final text = json['text'];
    String? description;
    if (text is Map) {
      description = text['text'];
    } else {
      description = text;
    }

    return Prediction(
      description: description,
      placeId: json['placeId'],
      structuredFormatting: description != null
          ? StructuredFormatting(mainText: description, secondaryText: null)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['description'] = description;
    data['place_id'] = placeId;
    if (structuredFormatting != null) {
      data['structured_formatting'] = structuredFormatting!.toJson();
    }
    data['lat'] = lat;
    data['lng'] = lng;
    return data;
  }
}

class StructuredFormatting {
  final String? mainText;
  final String? secondaryText;

  StructuredFormatting({this.mainText, this.secondaryText});

  factory StructuredFormatting.fromJson(Map<String, dynamic> json) {
    return StructuredFormatting(
      mainText: json['main_text'],
      secondaryText: json['secondary_text'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['main_text'] = mainText;
    data['secondary_text'] = secondaryText;
    return data;
  }
}