import 'package:cloud_firestore/cloud_firestore.dart';

class TareaChecklistService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> registrarTareasChecklist() async {
    try {
      final ordenesSnapshot = await _firestore
          .collection('ordenes_trabajo')
          .get();

      if (ordenesSnapshot.docs.isEmpty) {
        return;
      }

      final List<int> ordenesIds = ordenesSnapshot.docs.map((doc) {
        return int.parse(doc.id);
      }).toList();

      final List<Map<String, dynamic>> tareas = [
        {
          'idTarea': 1,
          'idOrden': 1,
          'descripcion': 'Revisar fugas de gas en sistema de refrigeración',
          'estadoCompletada': true,
          'horaCompletado': '08:15',
          'notaTarea': 'No se detectaron fugas. Presión estable a 120 PSI.',
        },
        {
          'idTarea': 2,
          'idOrden': 1,
          'descripcion': 'Verificar niveles de refrigerante',
          'estadoCompletada': true,
          'horaCompletado': '08:30',
          'notaTarea': 'Nivel óptimo: 85%. Refrigerante R-410A.',
        },
        {
          'idTarea': 3,
          'idOrden': 1,
          'descripcion': 'Limpiar condensadores y evaporadores',
          'estadoCompletada': true,
          'horaCompletado': '09:00',
          'notaTarea': 'Limpieza completada. Eficiencia mejorada.',
        },
        {
          'idTarea': 4,
          'idOrden': 1,
          'descripcion': 'Realizar prueba de presión del sistema',
          'estadoCompletada': false,
          'horaCompletado': null,
          'notaTarea': 'Pendiente de programar con el cliente.',
        },

        // ==================== ORDEN #2 (4 tareas) ====================
        {
          'idTarea': 5,
          'idOrden': 2,
          'descripcion': 'Revisar temperatura de servidores',
          'estadoCompletada': true,
          'horaCompletado': '09:20',
          'notaTarea': 'Temperatura: 22°C. Dentro del rango óptimo.',
        },
        {
          'idTarea': 6,
          'idOrden': 2,
          'descripcion': 'Verificar respaldos de datos',
          'estadoCompletada': true,
          'horaCompletado': '09:45',
          'notaTarea': 'Respaldos completados al 100%. 5 TB respaldados.',
        },
        {
          'idTarea': 7,
          'idOrden': 2,
          'descripcion': 'Limpiar ventiladores y filtros de servidores',
          'estadoCompletada': false,
          'horaCompletado': null,
          'notaTarea': 'Pendiente: filtros en espera de repuesto.',
        },
        {
          'idTarea': 8,
          'idOrden': 2,
          'descripcion': 'Actualizar software de seguridad',
          'estadoCompletada': true,
          'horaCompletado': '10:30',
          'notaTarea': 'Actualización completada. Versión 5.2.1.',
        },

        // ==================== ORDEN #3 (4 tareas) ====================
        {
          'idTarea': 9,
          'idOrden': 3,
          'descripcion': 'Instalar sensores de movimiento',
          'estadoCompletada': true,
          'horaCompletado': '11:00',
          'notaTarea': '12 sensores instalados en zonas estratégicas.',
        },
        {
          'idTarea': 10,
          'idOrden': 3,
          'descripcion': 'Conectar cámaras de seguridad',
          'estadoCompletada': true,
          'horaCompletado': '11:30',
          'notaTarea': '8 cámaras IP conectadas y configuradas.',
        },
        {
          'idTarea': 11,
          'idOrden': 3,
          'descripcion': 'Configurar sistema de alarmas',
          'estadoCompletada': false,
          'horaCompletado': null,
          'notaTarea': 'Pendiente: esperando código de acceso del cliente.',
        },
        {
          'idTarea': 12,
          'idOrden': 3,
          'descripcion': 'Probar funcionamiento del sistema completo',
          'estadoCompletada': false,
          'horaCompletado': null,
          'notaTarea': 'Pendiente de prueba final.',
        },

        // ==================== ORDEN #4 (4 tareas) ====================
        {
          'idTarea': 13,
          'idOrden': 4,
          'descripcion': 'Diagnosticar falla en equipo de refrigeración',
          'estadoCompletada': true,
          'horaCompletado': '13:00',
          'notaTarea': 'Falla diagnosticada: compresor con desgaste.',
        },
        {
          'idTarea': 14,
          'idOrden': 4,
          'descripcion': 'Reemplazar piezas dañadas del compresor',
          'estadoCompletada': true,
          'horaCompletado': '14:15',
          'notaTarea': 'Compresor reemplazado. Piezas originales.',
        },
        {
          'idTarea': 15,
          'idOrden': 4,
          'descripcion': 'Recargar gas refrigerante',
          'estadoCompletada': true,
          'horaCompletado': '14:45',
          'notaTarea': 'Carga completada: 3.5 kg de R-134A.',
        },
        {
          'idTarea': 16,
          'idOrden': 4,
          'descripcion': 'Realizar prueba de enfriamiento',
          'estadoCompletada': false,
          'horaCompletado': null,
          'notaTarea': 'Pendiente: estabilizar temperatura por 4 horas.',
        },

        // ==================== ORDEN #5 (4 tareas) ====================
        {
          'idTarea': 17,
          'idOrden': 5,
          'descripcion': 'Revisar sistema hidráulico de maquinaria',
          'estadoCompletada': true,
          'horaCompletado': '07:30',
          'notaTarea': 'Sistema hidráulico operando a 2000 PSI.',
        },
        {
          'idTarea': 18,
          'idOrden': 5,
          'descripcion': 'Lubricar partes móviles de la maquinaria',
          'estadoCompletada': true,
          'horaCompletado': '08:00',
          'notaTarea': 'Lubricación completada. Aceite SAE 40.',
        },
        {
          'idTarea': 19,
          'idOrden': 5,
          'descripcion': 'Cambiar filtros y aceite del motor',
          'estadoCompletada': true,
          'horaCompletado': '08:45',
          'notaTarea': 'Filtros cambiados. Aceite nuevo 25 litros.',
        },
        {
          'idTarea': 20,
          'idOrden': 5,
          'descripcion': 'Realizar prueba de carga y rendimiento',
          'estadoCompletada': false,
          'horaCompletado': null,
          'notaTarea': 'Pendiente: esperando carga de prueba.',
        },

        // ==================== ORDEN #6 (4 tareas) ====================
        {
          'idTarea': 21,
          'idOrden': 6,
          'descripcion': 'Instalar líneas de producción nuevas',
          'estadoCompletada': true,
          'horaCompletado': '10:00',
          'notaTarea': 'Líneas instaladas según plano técnico.',
        },
        {
          'idTarea': 22,
          'idOrden': 6,
          'descripcion': 'Conectar sistema eléctrico de producción',
          'estadoCompletada': true,
          'horaCompletado': '10:45',
          'notaTarea': 'Conexión eléctrica completada. 480V 3 fases.',
        },
        {
          'idTarea': 23,
          'idOrden': 6,
          'descripcion': 'Configurar controladores PLC',
          'estadoCompletada': false,
          'horaCompletado': null,
          'notaTarea': 'Pendiente: configuración de software especializado.',
        },
        {
          'idTarea': 24,
          'idOrden': 6,
          'descripcion': 'Realizar prueba de producción inicial',
          'estadoCompletada': false,
          'horaCompletado': null,
          'notaTarea': 'Pendiente: programar con equipo de producción.',
        },

        // ==================== ORDEN #7 (4 tareas) ====================
        {
          'idTarea': 25,
          'idOrden': 7,
          'descripcion': 'Revisar frenos y sistemas de seguridad',
          'estadoCompletada': true,
          'horaCompletado': '13:30',
          'notaTarea': 'Frenos operativos. Pastillas al 80% de vida.',
        },
        {
          'idTarea': 26,
          'idOrden': 7,
          'descripcion': 'Cambiar llantas y neumáticos',
          'estadoCompletada': true,
          'horaCompletado': '14:15',
          'notaTarea': '4 neumáticos nuevos instalados. Rodado 22.',
        },
        {
          'idTarea': 27,
          'idOrden': 7,
          'descripcion': 'Revisar motor y transmisión',
          'estadoCompletada': true,
          'horaCompletado': '15:00',
          'notaTarea': 'Motor y transmisión en óptimas condiciones.',
        },
        {
          'idTarea': 28,
          'idOrden': 7,
          'descripcion': 'Realizar prueba de ruta',
          'estadoCompletada': false,
          'horaCompletado': null,
          'notaTarea': 'Pendiente: prueba en carretera de 50 km.',
        },

        // ==================== ORDEN #8 (4 tareas) ====================
        {
          'idTarea': 29,
          'idOrden': 8,
          'descripcion': 'Revisar servidores y almacenamiento',
          'estadoCompletada': true,
          'horaCompletado': '09:00',
          'notaTarea': 'Servidores al 70% de capacidad. Estado OK.',
        },
        {
          'idTarea': 30,
          'idOrden': 8,
          'descripcion': 'Verificar seguridad de red',
          'estadoCompletada': true,
          'horaCompletado': '09:30',
          'notaTarea': 'Red segura. Firewall activo sin vulnerabilidades.',
        },
        {
          'idTarea': 31,
          'idOrden': 8,
          'descripcion': 'Actualizar sistemas operativos',
          'estadoCompletada': false,
          'horaCompletado': null,
          'notaTarea': 'Pendiente: actualización programada para fin de mes.',
        },
        {
          'idTarea': 32,
          'idOrden': 8,
          'descripcion': 'Probar respaldo y recuperación',
          'estadoCompletada': true,
          'horaCompletado': '10:45',
          'notaTarea': 'Prueba exitosa. Recuperación en 3 minutos.',
        },

        // ==================== ORDEN #9 (4 tareas) ====================
        {
          'idTarea': 33,
          'idOrden': 9,
          'descripcion': 'Inspeccionar equipos de perforación',
          'estadoCompletada': true,
          'horaCompletado': '11:00',
          'notaTarea': 'Equipos en buen estado. Sin desgaste crítico.',
        },
        {
          'idTarea': 34,
          'idOrden': 9,
          'descripcion': 'Revisar sistemas de seguridad',
          'estadoCompletada': true,
          'horaCompletado': '11:30',
          'notaTarea': 'Sistemas de seguridad operativos al 100%.',
        },
        {
          'idTarea': 35,
          'idOrden': 9,
          'descripcion': 'Realizar mantenimiento de motores diésel',
          'estadoCompletada': false,
          'horaCompletado': null,
          'notaTarea': 'Pendiente: esperando repuestos de motor.',
        },
        {
          'idTarea': 36,
          'idOrden': 9,
          'descripcion': 'Probar funcionamiento en terreno',
          'estadoCompletada': false,
          'horaCompletado': null,
          'notaTarea': 'Pendiente: condiciones climáticas adversas.',
        },

        // ==================== ORDEN #10 (4 tareas) ====================
        {
          'idTarea': 37,
          'idOrden': 10,
          'descripcion': 'Realizar limpieza general de instalaciones',
          'estadoCompletada': true,
          'horaCompletado': '15:30',
          'notaTarea': 'Limpieza completada. Instalaciones impecables.',
        },
        {
          'idTarea': 38,
          'idOrden': 10,
          'descripcion': 'Revisar sistema eléctrico completo',
          'estadoCompletada': true,
          'horaCompletado': '16:00',
          'notaTarea': 'Sistema eléctrico revisado. Sin anomalías.',
        },
        {
          'idTarea': 39,
          'idOrden': 10,
          'descripcion': 'Mantener equipos de oficina',
          'estadoCompletada': true,
          'horaCompletado': '16:30',
          'notaTarea': 'Equipos de oficina limpios y calibrados.',
        },
        {
          'idTarea': 40,
          'idOrden': 10,
          'descripcion': 'Realizar prueba final de todos los sistemas',
          'estadoCompletada': false,
          'horaCompletado': null,
          'notaTarea': 'Pendiente: inspección final del cliente.',
        },
      ];

      for (var tarea in tareas) {
        final docRef = _firestore
            .collection('tareas_checklist')
            .doc(tarea['idTarea'].toString());

        final docSnapshot = await docRef.get();

        if (!docSnapshot.exists) {
          await docRef.set({...tarea, 'fechaCreacion': DateTime.now()});
        } else {
          print('Tarea #${tarea['idTarea']} ya existe');
        }
      }
    } catch (e) {
      print('Error al registrar tareas: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAllTareas() async {
    try {
      final snapshot = await _firestore
          .collection('tareas_checklist')
          .orderBy('idTarea')
          .get();

      return snapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Obtener tareas por orden
  Future<List<Map<String, dynamic>>> getTareasByOrden(int idOrden) async {
    try {
      final snapshot = await _firestore
          .collection('tareas_checklist')
          .where('idOrden', isEqualTo: idOrden)
          .orderBy('idTarea')
          .get();

      return snapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }).toList();
    } catch (e) {
      print('Error al obtener tareas por orden: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getTareasCompletadas() async {
    try {
      final snapshot = await _firestore
          .collection('tareas_checklist')
          .where('estadoCompletada', isEqualTo: true)
          .orderBy('idTarea')
          .get();

      return snapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }).toList();
    } catch (e) {
      print('Error al obtener tareas completadas: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getTareasPendientes() async {
    try {
      final snapshot = await _firestore
          .collection('tareas_checklist')
          .where('estadoCompletada', isEqualTo: false)
          .orderBy('idTarea')
          .get();

      return snapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }).toList();
    } catch (e) {
      print('Error al obtener tareas pendientes: $e');
      return [];
    }
  }

  /// Obtener estadísticas de tareas
  Future<Map<String, dynamic>> getEstadisticasTareas() async {
    try {
      final tareas = await getAllTareas();

      int total = tareas.length;
      int completadas = 0;
      int pendientes = 0;

      for (var tarea in tareas) {
        if (tarea['estadoCompletada'] as bool) {
          completadas++;
        } else {
          pendientes++;
        }
      }

      return {
        'total': total,
        'completadas': completadas,
        'pendientes': pendientes,
        'porcentajeCompletado': total > 0
            ? ((completadas / total) * 100).round()
            : 0,
      };
    } catch (e) {
      print('Error al obtener estadísticas: $e');
      return {};
    }
  }

  Future<void> completarTarea(int idTarea, String nota) async {
    try {
      await _firestore
          .collection('tareas_checklist')
          .doc(idTarea.toString())
          .update({
            'estadoCompletada': true,
            'horaCompletado': DateTime.now().toString().substring(11, 16),
            'notaTarea': nota,
            'updatedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateNotaTarea(int idTarea, String nuevaNota) async {
    try {
      await _firestore
          .collection('tareas_checklist')
          .doc(idTarea.toString())
          .update({
            'notaTarea': nuevaNota,
            'updatedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<Map<String, dynamic>>> streamAllTareas() {
    return _firestore
        .collection('tareas_checklist')
        .orderBy('idTarea')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
          }).toList();
        });
  }

  Stream<List<Map<String, dynamic>>> streamTareasByOrden(int idOrden) {
    return _firestore
        .collection('tareas_checklist')
        .where('idOrden', isEqualTo: idOrden)
        .orderBy('idTarea')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
          }).toList();
        });
  }
}
