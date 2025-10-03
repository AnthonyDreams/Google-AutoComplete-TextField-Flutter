# Google Places API Migration - Legacy to New API

## Overview
This package has been updated to use the **new Google Places API** (places.googleapis.com/v1) instead of the legacy API that was deprecated as of March 1, 2025.

## What Changed

### 1. API Endpoints
- **Autocomplete (Old)**: `https://maps.googleapis.com/maps/api/place/autocomplete/json` (GET)
- **Autocomplete (New)**: `https://places.googleapis.com/v1/places:autocomplete` (POST)

- **Place Details (Old)**: `https://maps.googleapis.com/maps/api/place/details/json` (GET)
- **Place Details (New)**: `https://places.googleapis.com/v1/places/{PLACE_ID}` (GET)

### 2. Authentication
- **Old**: API key passed as URL parameter (`?key=YOUR_API_KEY`)
- **New**: API key passed in header (`X-Goog-Api-Key: YOUR_API_KEY`)

### 3. Request Format
- **Old**: Query parameters in URL
- **New**: 
  - Autocomplete uses POST with JSON body
  - Requires field masks in header (`X-Goog-FieldMask`)

### 4. Response Structure Changes

#### Autocomplete Response
**Old Format:**
```json
{
  "predictions": [
    {
      "description": "Place name",
      "place_id": "ChIJ...",
      "structured_formatting": {...}
    }
  ],
  "status": "OK"
}
```

**New Format:**
```json
{
  "suggestions": [
    {
      "placePrediction": {
        "placeId": "ChIJ...",
        "text": {
          "text": "Place name"
        }
      }
    }
  ]
}
```

#### Place Details Response
**Old Format:**
```json
{
  "result": {
    "geometry": {
      "location": {
        "lat": 40.7128,
        "lng": -74.0060
      }
    },
    "name": "Place Name",
    "formatted_address": "123 Main St"
  },
  "status": "OK"
}
```

**New Format:**
```json
{
  "id": "ChIJ...",
  "displayName": {
    "text": "Place Name"
  },
  "formattedAddress": "123 Main St",
  "location": {
    "latitude": 40.7128,
    "longitude": -74.0060
  }
}
```

### 5. Parameter Name Changes
- `language` → `languageCode`
- `components=country:XX` → `includedRegionCodes: ["XX"]`
- `types` → `includedPrimaryTypes`
- `location` + `radius` → `locationBias` with circle object
- `lat`/`lng` → `latitude`/`longitude`

## Files Modified

1. **lib/google_places_flutter.dart**
   - Updated `getLocation()` to use new autocomplete endpoint with POST
   - Updated `getPlaceDetailsFromPlaceId()` to use new place details endpoint
   - Added proper headers including field masks

2. **lib/model/prediction.dart**
   - Updated `PlacesAutocompleteResponse.fromJson()` to handle new `suggestions` structure
   - Updated `Prediction.fromJson()` to handle new `text` and `placeId` fields
   - Maintained backward compatibility with legacy format

3. **lib/model/place_details.dart**
   - Updated `PlaceDetails.fromJson()` to handle flat structure
   - Updated `Result.fromJson()` to handle new field names
   - Updated `Location.fromJson()` to handle `latitude`/`longitude` fields
   - Maintained backward compatibility with legacy format

## Migration Checklist

To use the new API, you must:

1. ✅ Enable the **Places API (New)** in Google Cloud Console
2. ✅ Update code to use new endpoints (already done in this package)
3. ⚠️ Verify your API key has access to the new API
4. ⚠️ Check billing is enabled (new API has different pricing)
5. ⚠️ Test thoroughly as response structures have changed

## Backward Compatibility

The model classes have been updated to support **both** the legacy and new API response formats. This means:
- Existing code using this package should continue to work
- The package will automatically detect and parse both formats
- However, you should migrate to the new API in Google Cloud Console

## Testing Recommendations

1. Test autocomplete functionality with various inputs
2. Verify place details are fetched correctly with lat/lng
3. Test country filtering if you use it
4. Test place type filtering if you use it
5. Test location bias/radius if you use it

## Important Notes

⚠️ **The legacy Places API may stop working after Google's deprecation deadline**. Ensure you:
1. Have enabled the new Places API in Google Cloud Console
2. Have updated your billing to support the new API
3. Have tested the integration thoroughly

## References
- [Google Places API (New) Documentation](https://developers.google.com/maps/documentation/places/web-service/overview)
- [Migration Guide](https://developers.google.com/maps/documentation/places/web-service/migrate-overview)
- [Place Autocomplete (New)](https://developers.google.com/maps/documentation/places/web-service/place-autocomplete)
- [Place Details (New)](https://developers.google.com/maps/documentation/places/web-service/place-details)



