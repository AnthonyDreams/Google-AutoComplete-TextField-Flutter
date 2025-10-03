class PlaceType {
  final String apiString;
  const PlaceType(this.apiString);

  static const geocode = PlaceType("geocode");
  static const address = PlaceType("address");
  static const establishment = PlaceType("establishment");


  static const regions = PlaceType("(regions)");
  static const cities = PlaceType("(cities)");
}