import 'package:flutter/material.dart';
import 'package:logistics_pro/features/admin/domain/entities/orden_trabajo_entity.dart';
import 'package:logistics_pro/features/admin/domain/usecases/create_orden_usecase.dart';
import 'package:logistics_pro/features/admin/domain/usecases/get_ordenes_usecase.dart';

enum OrdenState { initial, loading, success, error }
class OrdenesController extends ChangeNotifier{
  final CreateOrdenUsecase createOrdenUsecase;
  final GetOrdenesUsecase getOrdenesUsecase;
  OrdenesController(this.createOrdenUsecase, this.getOrdenesUsecase);

  OrdenState _status = OrdenState.initial;
  String? _errorMessage;

  OrdenState get status => _status;
  String? get errorMessage => _errorMessage;

  Future<void> createOrden(OrdenTrabajoEntity orden) async{
    _status = OrdenState.loading;
    _errorMessage = null;
    notifyListeners();
    try{
      await createOrdenUsecase(orden);
      _status = OrdenState.success; 
    }catch(e){
      _status = OrdenState.error;
      _errorMessage = e.toString().replaceAll('Exception', '');
    }
    notifyListeners();
  }

  Stream<List<OrdenTrabajoEntity>> get ordenesStream => getOrdenesUsecase();

  void resetState(){
    _status = OrdenState.initial;
  }
}