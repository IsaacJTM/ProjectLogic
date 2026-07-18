import 'package:cloud_firestore/cloud_firestore.dart';

class OrdenTrabajoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<void> registrarOrdenesEjemplo() async {
    try {
      final clientesSnapshot = await _firestore.collection('clientes').get();
      final List<int> clientesIds = clientesSnapshot.docs.map((doc) {
        return doc['idCliente'] as int;
      }).toList();

      if (clientesIds.isEmpty) {
        return;
      }

      final List<Map<String, dynamic>> ordenes = [
        {
          'idOrden': 1,
          'nroOrden': 1001,
          'idCliente': clientesIds[0], // TechSolutions S.A.C.
          'idUsuario': 'manuel.rm@worker.com',
          'estadoFase': 0, // Asignado
          'tiempoEjecucion': 0,
          'notasGenerales': 'Revisión de equipos de refrigeración',
          'fechaAsignacionOrden': DateTime.now().subtract(
            const Duration(hours: 2),
          ),
          'fechaFinalizacionOrden': null,
        },
        {
          'idOrden': 2,
          'nroOrden': 1002,
          'idCliente': clientesIds[1], // Importaciones Globales E.I.R.L.
          'idUsuario': 'manuel.rm@worker.com',
          'estadoFase': 1, // En ruta
          'tiempoEjecucion': 15,
          'notasGenerales': 'Mantenimiento preventivo de servidores',
          'fechaAsignacionOrden': DateTime.now().subtract(
            const Duration(hours: 1),
          ),
          'fechaFinalizacionOrden': null,
        },
        {
          'idOrden': 3,
          'nroOrden': 1003,
          'idCliente': clientesIds[2], // Servicios Industriales Norte S.A.
          'idUsuario': 'manuel.rm@worker.com',
          'estadoFase': 2, // En sitio
          'tiempoEjecucion': 30,
          'notasGenerales': 'Instalación de sistema de seguridad',
          'fechaAsignacionOrden': DateTime.now().subtract(
            const Duration(hours: 3),
          ),
          'fechaFinalizacionOrden': null,
        },
        {
          'idOrden': 4,
          'nroOrden': 1004,
          'idCliente': clientesIds[3], // Distribuidora San Miguel S.R.L.
          'idUsuario': 'manuel.rm@worker.com',
          'estadoFase': 3, // Ejecución
          'tiempoEjecucion': 45,
          'notasGenerales': 'Reparación de equipo de refrigeración',
          'fechaAsignacionOrden': DateTime.now().subtract(
            const Duration(hours: 4),
          ),
          'fechaFinalizacionOrden': null,
        },
        {
          'idOrden': 5,
          'nroOrden': 1005,
          'idCliente': clientesIds[4], // Constructora Andina S.A.C.
          'idUsuario': 'manuel.rm@worker.com',
          'estadoFase': 4, // Finalizado
          'tiempoEjecucion': 120,
          'notasGenerales': 'Mantenimiento de maquinaria pesada - Completado',
          'fechaAsignacionOrden': DateTime.now().subtract(
            const Duration(days: 1),
          ),
          'fechaFinalizacionOrden': DateTime.now().subtract(
            const Duration(hours: 2),
          ),
        },
        {
          'idOrden': 6,
          'nroOrden': 1006,
          'idCliente': clientesIds[5], // Alimentos del Perú S.A.
          'idUsuario': 'manuel.rm@worker.com',
          'estadoFase': 0, // Asignado
          'tiempoEjecucion': 0,
          'notasGenerales': 'Instalación de líneas de producción',
          'fechaAsignacionOrden': DateTime.now().subtract(
            const Duration(hours: 5),
          ),
          'fechaFinalizacionOrden': null,
        },
        {
          'idOrden': 7,
          'nroOrden': 1007,
          'idCliente': clientesIds[6],
          'idUsuario': 'manuel.rm@worker.com',
          'estadoFase': 1, // En ruta
          'tiempoEjecucion': 10,
          'notasGenerales': 'Revisión de flota de vehículos',
          'fechaAsignacionOrden': DateTime.now().subtract(
            const Duration(hours: 30),
          ),
          'fechaFinalizacionOrden': null,
        },
        {
          'idOrden': 8,
          'nroOrden': 1008,
          'idCliente': clientesIds[7],
          'idUsuario': 'manuel.rm@worker.com',
          'estadoFase': 2, // En sitio
          'tiempoEjecucion': 25,
          'notasGenerales': 'Mantenimiento de servidores y redes',
          'fechaAsignacionOrden': DateTime.now().subtract(
            const Duration(hours: 20),
          ),
          'fechaFinalizacionOrden': null,
        },
        {
          'idOrden': 9,
          'nroOrden': 1009,
          'idCliente': clientesIds[8], // Minería y Construcción S.A.
          'idUsuario': 'manuel.rm@worker.com',
          'estadoFase': 3, // Ejecución
          'tiempoEjecucion': 60,
          'notasGenerales': 'Reparación de equipos de minería',
          'fechaAsignacionOrden': DateTime.now().subtract(
            const Duration(days: 2),
          ),
          'fechaFinalizacionOrden': null,
        },
        {
          'idOrden': 10,
          'nroOrden': 1010,
          'idCliente': clientesIds[9], // Servicios Generales Centro S.A.C.
          'idUsuario': 'manuel.rm@worker.com',
          'estadoFase': 4, // Finalizado
          'tiempoEjecucion': 90,
          'notasGenerales': 'Mantenimiento general - Completado',
          'fechaAsignacionOrden': DateTime.now().subtract(
            const Duration(days: 3),
          ),
          'fechaFinalizacionOrden': DateTime.now().subtract(
            const Duration(days: 1),
          ),
        },
      ];

      for (var orden in ordenes) {
        final docRef = _firestore
            .collection('ordenes_trabajo')
            .doc(orden['idOrden'].toString());

        final docSnapshot = await docRef.get();

        if (!docSnapshot.exists) {
          await docRef.set({
            'idOrden': orden['idOrden'],
            'nroOrden': orden['nroOrden'],
            'idCliente': orden['idCliente'],
            'idUsuario': orden['idUsuario'],
            'estadoFase': orden['estadoFase'],
            'tiempoEjecucion': orden['tiempoEjecucion'],
            'notasGenerales': orden['notasGenerales'],
            'fechaAsignacionOrden': orden['fechaAsignacionOrden'],
            'fechaFinalizacionOrden': orden['fechaFinalizacionOrden'],
            'fechaCreacion': FieldValue.serverTimestamp(),
          });
        } else {}
      }
    } catch (e) {
      rethrow;
    }
  }

  String _getEstadoFaseText(int fase) {
    switch (fase) {
      case 0:
        return 'Asignado';
      case 1:
        return 'En ruta';
      case 2:
        return 'En sitio';
      case 3:
        return 'Ejecución';
      case 4:
        return 'Finalizado';
      default:
        return 'Desconocido';
    }
  }

  Future<bool> existenOrdenes() async {
    try {
      final snapshot = await _firestore
          .collection('ordenes_trabajo')
          .limit(1)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getAllOrdenes() async {
    try {
      final snapshot = await _firestore
          .collection('ordenes_trabajo')
          .orderBy('idOrden')
          .get();

      return snapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getOrdenesByCliente(int idCliente) async {
    try {
      final snapshot = await _firestore
          .collection('ordenes_trabajo')
          .where('idCliente', isEqualTo: idCliente)
          .orderBy('fechaAsignacionOrden', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getOrdenesByEmpleado(String email) async {
    try {
      final snapshot = await _firestore
          .collection('ordenes_trabajo')
          .where('idUsuario', isEqualTo: email)
          .orderBy('fechaAsignacionOrden', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getOrdenesByEstado(int estadoFase) async {
    try {
      final snapshot = await _firestore
          .collection('ordenes_trabajo')
          .where('estadoFase', isEqualTo: estadoFase)
          .orderBy('fechaAsignacionOrden', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getOrdenesByFechaRango({
    required DateTime fechaInicio,
    required DateTime fechaFin,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('ordenes_trabajo')
          .where('fechaAsignacionOrden', isGreaterThanOrEqualTo: fechaInicio)
          .where('fechaAsignacionOrden', isLessThanOrEqualTo: fechaFin)
          .orderBy('fechaAsignacionOrden', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getOrdenesWithCliente() async {
    try {
      final ordenes = await getAllOrdenes();
      final List<Map<String, dynamic>> resultado = [];

      for (var orden in ordenes) {
        final idCliente = orden['idCliente'] as int;
        final clienteDoc = await _firestore
            .collection('clientes')
            .doc(idCliente.toString())
            .get();

        final clienteData = clienteDoc.data() as Map<String, dynamic>? ?? {};

        resultado.add({
          ...orden,
          'cliente': {
            'idCliente': idCliente,
            'nombreEmpresa': clienteData['nombreEmpresa'] ?? 'Sin empresa',
            'direccionfisica':
                clienteData['direccionfisica'] ?? 'Sin dirección',
            'telefonoContacto':
                clienteData['telefonoContacto'] ?? 'Sin teléfono',
          },
        });
      }

      return resultado;
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getOrdenesWithClienteYEmpleado() async {
    try {
      final ordenes = await getAllOrdenes();
      final List<Map<String, dynamic>> resultado = [];

      for (var orden in ordenes) {
        // Obtener cliente
        final idCliente = orden['idCliente'] as int;
        final clienteDoc = await _firestore
            .collection('clientes')
            .doc(idCliente.toString())
            .get();
        final clienteData = clienteDoc.data() as Map<String, dynamic>? ?? {};

        // Obtener empleado
        final idUsuario = orden['idUsuario'] as String;
        final empleadoDoc = await _firestore
            .collection('usuarios')
            .doc(idUsuario)
            .get();
        final empleadoData = empleadoDoc.data() as Map<String, dynamic>? ?? {};

        resultado.add({
          ...orden,
          'cliente': {
            'idCliente': idCliente,
            'nombreEmpresa': clienteData['nombreEmpresa'] ?? 'Sin empresa',
            'direccionfisica':
                clienteData['direccionfisica'] ?? 'Sin dirección',
            'telefonoContacto':
                clienteData['telefonoContacto'] ?? 'Sin teléfono',
          },
          'empleado': {
            'email': idUsuario,
            'nombreApellido': empleadoData['nombreApellido'] ?? 'Sin nombre',
            'cargo': empleadoData['cargo'] ?? 'Sin cargo',
            'usuario': empleadoData['usuario'] ?? 'Sin usuario',
          },
        });
      }

      return resultado;
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> getEstadisticasOrdenes() async {
    try {
      final ordenes = await getAllOrdenes();

      int total = ordenes.length;
      int asignadas = 0;
      int enRuta = 0;
      int enSitio = 0;
      int ejecucion = 0;
      int finalizadas = 0;
      int tiempoTotal = 0;

      for (var orden in ordenes) {
        final fase = orden['estadoFase'] as int;
        switch (fase) {
          case 0:
            asignadas++;
            break;
          case 1:
            enRuta++;
            break;
          case 2:
            enSitio++;
            break;
          case 3:
            ejecucion++;
            break;
          case 4:
            finalizadas++;
            break;
        }
        tiempoTotal += orden['tiempoEjecucion'] as int? ?? 0;
      }

      return {
        'total': total,
        'asignadas': asignadas,
        'enRuta': enRuta,
        'enSitio': enSitio,
        'ejecucion': ejecucion,
        'finalizadas': finalizadas,
        'tiempoTotalEjecucion': tiempoTotal,
        'tiempoPromedio': total > 0 ? (tiempoTotal / total).round() : 0,
      };
    } catch (e) {
      return {};
    }
  }

  Future<void> updateEstadoFase(int idOrden, int nuevoEstado) async {
    try {
      await _firestore
          .collection('ordenes_trabajo')
          .doc(idOrden.toString())
          .update({
            'estadoFase': nuevoEstado,
            'updatedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateTiempoEjecucion(int idOrden, int tiempo) async {
    try {
      await _firestore
          .collection('ordenes_trabajo')
          .doc(idOrden.toString())
          .update({
            'tiempoEjecucion': tiempo,
            'updatedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> finalizarOrden(int idOrden, String notasFinales) async {
    try {
      await _firestore
          .collection('ordenes_trabajo')
          .doc(idOrden.toString())
          .update({
            'estadoFase': 4, // Finalizado
            'notasGenerales': notasFinales,
            'fechaFinalizacionOrden': DateTime.now(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteOrden(int idOrden) async {
    try {
      await _firestore
          .collection('ordenes_trabajo')
          .doc(idOrden.toString())
          .delete();
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<Map<String, dynamic>>> streamAllOrdenes() {
    return _firestore
        .collection('ordenes_trabajo')
        .orderBy('idOrden')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
          }).toList();
        });
  }

  Stream<List<Map<String, dynamic>>> streamOrdenesByEmpleado(String email) {
    return _firestore
        .collection('ordenes_trabajo')
        .where('idUsuario', isEqualTo: email)
        .orderBy('fechaAsignacionOrden', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
          }).toList();
        });
  }

  Stream<List<Map<String, dynamic>>> streamOrdenesByCliente(int idCliente) {
    return _firestore
        .collection('ordenes_trabajo')
        .where('idCliente', isEqualTo: idCliente)
        .orderBy('fechaAsignacionOrden', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
          }).toList();
        });
  }

  Stream<List<Map<String, dynamic>>> streamOrdenesByEstado(int estadoFase) {
    return _firestore
        .collection('ordenes_trabajo')
        .where('estadoFase', isEqualTo: estadoFase)
        .orderBy('fechaAsignacionOrden', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
          }).toList();
        });
  }
}
