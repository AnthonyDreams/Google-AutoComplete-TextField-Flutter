## 1.0.0

* Initial commit.

## 2.0.0

* Support country code

## 2.0.1

* Support multiple countries

## 2.0.2

* Get LatLng from Place detail

## 2.0.3

* Remove place-type field and improve the accuracy of search result

## 2.0.4

* Support Null Safety

## 2.0.5

* Support Null Safety and code improvement

## 2.0.6

* Support custom list item builder, error handled and minor fixes

## 2.0.7

* Update dio dependency and minor improvements 

## 2.0.8

* Bug fixes and improvements

## 2.0.9

* Filter added by PlaceType and language


## 2.1.0

* Added Near By Search and Some Bug fixes and improvements

## 2.1.1

* Added `keyboardType` parameter to customize the keyboard input type (defaults to `TextInputType.streetAddress` for better address input experience)
* Upgrade Rx library 

## 3.0.0

* **BREAKING**: Migrated from legacy Google Places API to new Places API (places.googleapis.com/v1)
* Changed autocomplete endpoint from GET to POST with new request format
* Updated place details endpoint to use new API format
* Added support for new API authentication using X-Goog-Api-Key header
* Added support for field masks as required by new API
* Updated response parsing to handle new API structure (suggestions.placePrediction format)
* Updated location fields to use latitude/longitude instead of lat/lng
* Maintained backward compatibility with legacy response format in models
* Fixed null safety issues when clearing text before overlay is created
* Fixed cancel token not being recreated after cancellation, preventing subsequent requests
* Suppress cancellation error messages to avoid showing "Request cancelled" to users
* **ACTION REQUIRED**: Enable "Places API (New)" in Google Cloud Console
* See MIGRATION_NOTES.md for detailed migration guide


