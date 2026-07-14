import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../domain/entities/coordinate_entity.dart';
import '../../../domain/usecases/track_technician_route_usecase.dart';

enum EnRouteStatus { idle, tracking, arrived }

class EnRouteController extends ChangeNotifier {
  final TrackTechnicianRouteUseCase trackRoute;
  StreamSubscription<CoordinateEntity>? _subscription;

  EnRouteController({required this.trackRoute});

  EnRouteStatus _status = EnRouteStatus.idle;
  CoordinateEntity? _lastPosition;

  EnRouteStatus get status => _status;
  CoordinateEntity? get lastPosition => _lastPosition;

  void startTracking(String orderId) {
    _status = EnRouteStatus.tracking;
    _lastPosition = null;
    notifyListeners();

    _subscription?.cancel();
    _subscription = trackRoute(orderId).listen((coord) {
      _lastPosition = coord;
      notifyListeners();
    });
  }

  void arrivedAtSite() {
    _status = EnRouteStatus.arrived;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
