import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logistics_pro/features/admin/data/models/orden_trabajo_model.dart';
import 'package:logistics_pro/features/admin/data/models/tarea_checklist_model.dart';

class OrdenesRemoteDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> guardarOrdenConChekList(OrdenTrabajoModel orden) async{
    final WriteBatch writeBatch = _firestore.batch();

    //Para crear el documento de la ORDEN
    final DocumentReference ordenRef = _firestore.collection('ordenes_trabajo').doc(orden.idOrden);
    writeBatch.set(ordenRef, orden.toMap());

    for(var actividad in orden.actividades){
      final tarea = TareaChecklistModel(
        idTarea: actividad.idTarea, 
        idOrden: actividad.idOrden, 
        descripcion: actividad.descripcion,
        estadoCompletado: actividad.estadoCompletado
      );

      //Para crear el documento de ACTIVIDAD
      final DocumentReference tareaRef = _firestore.collection('tareas_checklist').doc(actividad.idTarea);
      writeBatch.set(tareaRef, tarea.toMap());
    }

    //Para ejecutar la operación automática en Firebase
    await writeBatch.commit();
  }
}