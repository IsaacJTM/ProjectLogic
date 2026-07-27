import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logistics_pro/features/admin/data/models/orden_trabajo_model.dart';
import 'package:logistics_pro/features/admin/data/models/tarea_checklist_model.dart';
import 'package:logistics_pro/features/admin/domain/entities/orden_trabajo_entity.dart';

class OrdenesRemoteDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> guardarOrdenConChekList(OrdenTrabajoModel orden) async{
    final WriteBatch writeBatch = _firestore.batch();

    //Para crear el documento de la ORDEN
    final DocumentReference ordenRef = _firestore
                .collection('ordenes_trabajo')
                .doc(orden.idOrden.toString());
    writeBatch.set(ordenRef, orden.toMap());

    for(var actividad in orden.actividades){
      final tarea = TareaChecklistModel(
        idTarea: actividad.idTarea, 
        idOrden: actividad.idOrden, 
        descripcion: actividad.descripcion,
        estadoCompletada: actividad.estadoCompletada
      );

      //Para crear el documento de ACTIVIDAD
      final DocumentReference tareaRef = _firestore.collection('tareas_checklist').doc(actividad.idTarea.toString());
      writeBatch.set(tareaRef, tarea.toMap());
    }

    //Para ejecutar la operación automática en Firebase
    await writeBatch.commit();
  }

  Stream<List<OrdenTrabajoEntity>> getOrdenTrabajo(){
    return _firestore
            .collection('ordenes_trabajo')
            .orderBy('fechaCreacion', descending: true)
            .snapshots()
            .asyncMap((snapshotsOrdenes) async{
              List<OrdenTrabajoEntity>  listaOrdenes = [];
              for (var docOrden in snapshotsOrdenes.docs){
                final dataOrden = docOrden.data();
                final int idOrdenDoc = int.parse(docOrden.id);

                // Recuperamos de Firestores las tareas de checklist asociadas a la Orden
                final snapshotsTarea = await _firestore
                                        .collection('tareas_checklist')
                                        .where('idOrden', isEqualTo: idOrdenDoc)
                                        .get();
                final tareaList = snapshotsTarea.docs.map((docTarea){
                  //final dataTarea = docTarea.data();
                  return TareaChecklistModel(
                    idTarea: int.parse(docTarea.id), 
                    idOrden: docTarea['idOrden'] ?? '', 
                    descripcion: docTarea['descripcion'] ?? '',
                    estadoCompletada: docTarea['estadoCompletada'] ?? false
                  );
                }).toList();

                listaOrdenes.add(
                  OrdenTrabajoEntity(
                    idOrden: idOrdenDoc, 
                    idCliente: dataOrden['idCliente'] ?? '', //vuelve a pages 
                    idUsuario: dataOrden['idUsuario'] ?? '', 
                    nroOrden: dataOrden['nroOrden'] ?? 1001,
                    estadoFase: dataOrden['estadoFase'] ?? 0,
                    fechaCreacion: (dataOrden['fechaCreacion'] as Timestamp?)?.toDate() ?? DateTime.now(), 
                    fechaAsignacionOrden: (dataOrden['fechaAsignacionOrden'] as Timestamp?)?.toDate() ?? DateTime.now(),
                    titulo: dataOrden['notasGenerales'], 
                    nombreLugar: (dataOrden['nombreLugar'] as String?) ?? '',
                    latitud: (dataOrden['latitud'] as String?) ?? '',
                    longitud: (dataOrden['longitud'] as String?) ?? '',
                    actividades: tareaList
                  ),
                );
              }

              return listaOrdenes;
            });
  }
}