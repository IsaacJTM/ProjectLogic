import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logistics_pro/features/admin/domain/entities/tarea_checklist_entity.dart';

class TareaChecklistModel extends TareaChecklistEntity {
  TareaChecklistModel({
    required super.idTarea,
    required super.idOrden, 
    required super.descripcion,
    super.fechaCreacion,
    super.estadoCompletado
  });

  Map<String, dynamic> toMap(){
    return{
      'idTarea':idTarea,
      'idOrden': idOrden,
      'descripcion': descripcion,
      'fechaCreacion':fechaCreacion != null ? Timestamp.fromDate(fechaCreacion!) : null,
      'estadoCompletado': estadoCompletado
    };
  }

}