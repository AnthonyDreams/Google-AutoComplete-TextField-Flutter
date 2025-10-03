
class PlaceDetails {
  final Result? result;

  PlaceDetails({this.result});

  factory PlaceDetails.fromJson(Map<String, dynamic> json) {
    return PlaceDetails(
      result: Result.fromJson(json),
    );
  }
}

class Result {
  final String? name;
  final String? formattedAddress;
  final String? placeId;
  final Geometry? geometry;
  final List<Photo>? photos;

  Result({
    this.name,
    this.formattedAddress,
    this.placeId,
    this.geometry,
    this.photos,
  });

  factory Result.fromJson(Map<String, dynamic> json) {
    String? name;
    if (json['displayName'] != null) {
      if (json['displayName'] is Map) {
        name = json['displayName']['text'];
      } else {
        name = json['displayName'];
      }
    }

    return Result(
      name: name,
      formattedAddress: json['formattedAddress'],
      placeId: json['id'],
      geometry: json['location'] != null
          ? Geometry.fromJson({'location': json['location']})
          : null,
      photos: json['photos'] != null
          ? (json['photos'] as List)
              .map((photoJson) => Photo.fromJson(photoJson))
              .toList()
          : null,
    );
  }
}

class Photo {
  final String name;
  final int widthPx;
  final int heightPx;
  final List<AuthorAttribution> authorAttributions;

  Photo({
    required this.name,
    required this.widthPx,
    required this.heightPx,
    required this.authorAttributions,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      name: json['name'],
      widthPx: json['widthPx'],
      heightPx: json['heightPx'],
      authorAttributions: (json['authorAttributions'] as List)
          .map((e) => AuthorAttribution.fromJson(e))
          .toList(),
    );
  }

  String getPhotoUrl(String apiKey, {int maxHeightPx = 400}) {
    return 'https://places.googleapis.com/v1/$name/media?maxHeightPx=$maxHeightPx&key=$apiKey';
  }
}

class AuthorAttribution {
  final String displayName;
  final String uri;
  final String photoUri;

  AuthorAttribution({
    required this.displayName,
    required this.uri,
    required this.photoUri,
  });

  factory AuthorAttribution.fromJson(Map<String, dynamic> json) {
    return AuthorAttribution(
      displayName: json['displayName'],
      uri: json['uri'],
      photoUri: json['photoUri'],
    );
  }
}

class Geometry {
  final Location? location;

  Geometry({this.location});

  factory Geometry.fromJson(Map<String, dynamic> json) {
    return Geometry(
      location: json['location'] != null
          ? Location.fromJson(json['location'])
          : null,
    );
  }
}

class Location {
  final double? lat;
  final double? lng;

  Location({this.lat, this.lng});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      lat: json['latitude'] as double?,
      lng: json['longitude'] as double?,
    );
  }
}
