library google_places_flutter;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_places_flutter/model/place_details.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:dio/dio.dart';
import 'package:rxdart/rxdart.dart';

import 'DioErrorHandler.dart';
import 'model/place_type.dart';

class GooglePlaceAutoCompleteTextField extends StatefulWidget {
  final InputDecoration inputDecoration;
  final ItemClick? itemClick;
  final GetPlaceDetailswWithLatLng? getPlaceDetailWithLatLng;
  final bool isLatLngRequired;
  final TextStyle textStyle;
  final String googleAPIKey;
  final int debounceTime;
  final List<String>? countries;
  final TextEditingController textEditingController;
  final ListItemBuilder? itemBuilder;
  final Widget? seperatedBuilder;
  final BoxDecoration? boxDecoration;
  final bool isCrossBtnShown;
  final bool showError;
  final double? containerHorizontalPadding;
  final double? containerVerticalPadding;
  final FocusNode? focusNode;
  final PlaceType? placeType;
  final String? language;
  final TextInputAction? textInputAction;
  final VoidCallback? formSubmitCallback;
  final TextInputType? keyboardType;
  final String? Function(String?, BuildContext)? validator;
  final double? latitude;
  final double? longitude;
  final int? radius;
  final bool fullDetail;
  final void Function(PlaceDetails)? getPlaceDetailWithFullDetail;

  const GooglePlaceAutoCompleteTextField({
    Key? key,
    required this.textEditingController,
    required this.googleAPIKey,
    this.debounceTime = 600,
    this.inputDecoration = const InputDecoration(),
    this.itemClick,
    this.isLatLngRequired = true,
    this.textStyle = const TextStyle(),
    this.countries,
    this.getPlaceDetailWithLatLng,
    this.itemBuilder,
    this.boxDecoration,
    this.isCrossBtnShown = true,
    this.seperatedBuilder,
    this.showError = true,
    this.containerHorizontalPadding,
    this.containerVerticalPadding,
    this.focusNode,
    this.placeType,
    this.language = 'en',
    this.validator,
    this.latitude,
    this.longitude,
    this.radius,
    this.formSubmitCallback,
    this.textInputAction,
    this.keyboardType,
    this.fullDetail = false,
    this.getPlaceDetailWithFullDetail,
  }) : super(key: key);

  @override
  _GooglePlaceAutoCompleteTextFieldState createState() =>
      _GooglePlaceAutoCompleteTextFieldState();
}

class _GooglePlaceAutoCompleteTextFieldState
    extends State<GooglePlaceAutoCompleteTextField> {
  final _subject = PublishSubject<String>();
  OverlayEntry? _overlayEntry;
  List<Prediction> _predictions = [];
  final _layerLink = LayerLink();
  bool _isCrossBtn = true;
  final _dio = Dio();
  CancelToken? _cancelToken = CancelToken();

  @override
  void initState() {
    super.initState();
    _subject.stream
        .distinct()
        .debounceTime(Duration(milliseconds: widget.debounceTime))
        .listen(_textChanged);
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: widget.containerHorizontalPadding ?? 0,
          vertical: widget.containerVerticalPadding ?? 0,
        ),
        alignment: Alignment.centerLeft,
        decoration: widget.boxDecoration ??
            BoxDecoration(
              shape: BoxShape.rectangle,
              border: Border.all(color: Colors.grey, width: 0.6),
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: TextFormField(
                decoration: widget.inputDecoration,
                style: widget.textStyle,
                controller: widget.textEditingController,
                focusNode: widget.focusNode ?? FocusNode(),
                keyboardType: widget.keyboardType ?? TextInputType.streetAddress,
                textInputAction: widget.textInputAction ?? TextInputAction.done,
                onFieldSubmitted: (value) => widget.formSubmitCallback?.call(),
                validator: (inputString) =>
                    widget.validator?.call(inputString, context),
                onChanged: (string) {
                  _subject.add(string);
                  if (widget.isCrossBtnShown) {
                    setState(() => _isCrossBtn = string.isNotEmpty);
                  }
                },
              ),
            ),
            if (widget.isCrossBtnShown &&
                _isCrossBtn &&
                _showCrossIconWidget())
              IconButton(onPressed: _clearData, icon: const Icon(Icons.close)),
          ],
        ),
      ),
    );
  }

  void _textChanged(String text) {
    if (text.isNotEmpty) {
      _getLocation(text);
    } else {
      _clearPredictions();
    }
  }

  void _clearPredictions() {
    setState(() => _predictions.clear());
    _removeOverlay();
  }

  Future<void> _getLocation(String text) async {
    if (_cancelToken?.isCancelled == false) {
      _cancelToken?.cancel();
    }
    _cancelToken = CancelToken();

    const apiURL = 'https://places.googleapis.com/v1/places:autocomplete';

    final requestBody = <String, dynamic>{
      'input': text,
      'languageCode': widget.language ?? 'en',
      if (widget.countries != null && widget.countries!.isNotEmpty)
        'includedRegionCodes': widget.countries,
      if (widget.placeType != null)
        'includedPrimaryTypes': [widget.placeType!.apiString],
      if (widget.latitude != null &&
          widget.longitude != null &&
          widget.radius != null)
        'locationBias': {
          'circle': {
            'center': {
              'latitude': widget.latitude,
              'longitude': widget.longitude,
            },
            'radius': widget.radius!.toDouble(),
          }
        },
    };

    try {
      final response = await _dio.post(
        kIsWeb ? 'https://cors-anywhere.herokuapp.com/$apiURL' : apiURL,
        data: requestBody,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'X-Goog-Api-Key': widget.googleAPIKey,
            'X-Goog-FieldMask':
                'suggestions.placePrediction.placeId,suggestions.placePrediction.text',
          },
        ),
        cancelToken: _cancelToken,
      );

      if (response.data is Map) {
        final predictions = PlacesAutocompleteResponse.fromJson(response.data).predictions;
        if (widget.textEditingController.text.trim().isNotEmpty) {
          setState(() => _predictions = predictions);
        }
      }

      _showOverlay();
    } catch (e) {
      if (e is! DioException || e.type != DioExceptionType.cancel) {
        final errorHandler = ErrorHandler.internal().handleError(e);
        _showSnackBar(errorHandler.message ?? '');
      }
    }
  }

  void _showOverlay() {
    _removeOverlay();
    _overlayEntry = _createOverlayEntry();
    if (_overlayEntry != null) {
      Overlay.of(context).insert(_overlayEntry!); 
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry? _createOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final size = renderBox.size;
      final offset = renderBox.localToGlobal(Offset.zero);
      return OverlayEntry(
        builder: (context) => Positioned(
          left: offset.dx,
          top: size.height + offset.dy,
          width: size.width,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0.0, size.height + 5.0),
            child: Material(
              elevation: 4.0,
              child: ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: _predictions.length,
                separatorBuilder: (context, pos) =>
                    widget.seperatedBuilder ?? const SizedBox(),
                itemBuilder: (BuildContext context, int index) {
                  final prediction = _predictions[index];
                  return InkWell(
                    onTap: () async {
                      widget.itemClick?.call(prediction);
                      if (widget.fullDetail) {
                        await _getPlaceDetailsFromPlaceId(prediction, fullDetail: true);
                      } else if (widget.isLatLngRequired) {
                        await _getPlaceDetailsFromPlaceId(prediction);
                      }
                      _removeOverlay();
                    },
                    child: widget.itemBuilder != null
                        ? widget.itemBuilder!(context, index, prediction)
                        : Container(
                            padding: const EdgeInsets.all(10),
                            child: Text(prediction.description ?? ''),
                          ),
                  );
                },
              ),
            ),
          ),
        ),
      );
    }
    return null;
  }

  Future<void> _getPlaceDetailsFromPlaceId(Prediction prediction, {bool fullDetail = false}) async {
    final url =
        'https://places.googleapis.com/v1/places/${prediction.placeId}';

    final fieldMask = fullDetail
        ? 'id,displayName,formattedAddress,location,photos'
        : 'id,displayName,formattedAddress,location';

    try {
      final response = await _dio.get(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'X-Goog-Api-Key': widget.googleAPIKey,
            'X-Goog-FieldMask': fieldMask,
          },
        ),
      );

      final placeDetails = PlaceDetails.fromJson(response.data);

      if (fullDetail) {
        widget.getPlaceDetailWithFullDetail?.call(placeDetails);
      }

      final location = placeDetails.result?.geometry?.location;
      if (location != null) {
        prediction.lat = location.lat.toString();
        prediction.lng = location.lng.toString();
      }

      widget.getPlaceDetailWithLatLng?.call(prediction);
    } catch (e) {
      if (e is! DioException || e.type != DioExceptionType.cancel) {
        final errorHandler = ErrorHandler.internal().handleError(e);
        _showSnackBar(errorHandler.message ?? '');
      }
    }
  }

  void _clearData() {
    widget.textEditingController.clear();
    _cancelToken?.cancel();
    _clearPredictions();
    setState(() => _isCrossBtn = false);
  }

  bool _showCrossIconWidget() => widget.textEditingController.text.isNotEmpty;

  void _showSnackBar(String errorData) {
    if (widget.showError) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(errorData)));
    }
  }

  @override
  void dispose() {
    _subject.close();
    _cancelToken?.cancel();
    _dio.close();
    _removeOverlay();
    super.dispose();
  }
}

typedef ItemClick = void Function(Prediction prediction);
typedef GetPlaceDetailswWithLatLng = void Function(Prediction prediction);
typedef GetPlaceDetailWithFullDetail = void Function(PlaceDetails placeDetails);
typedef ListItemBuilder = Widget Function(
    BuildContext context, int index, Prediction prediction);