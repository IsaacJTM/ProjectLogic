enum OrderPhase { assigned, enRoute, onSite, execution, completed }

extension OrderPhaseX on OrderPhase {
  int get index0 => OrderPhase.values.indexOf(this);

  String get label {
    switch (this) {
      case OrderPhase.assigned:
        return 'Asignado';
      case OrderPhase.enRoute:
        return 'En Ruta';
      case OrderPhase.onSite:
        return 'En Sitio';
      case OrderPhase.execution:
        return 'Ejecución';
      case OrderPhase.completed:
        return 'Finalizado';
    }
  }

  /// null si ya está en la última fase.
  OrderPhase? get next {
    final i = index0;
    if (i >= OrderPhase.values.length - 1) return null;
    return OrderPhase.values[i + 1];
  }

  /// null si ya está en la primera fase (no se puede retroceder más).
  OrderPhase? get previous {
    final i = index0;
    if (i <= 0) return null;
    return OrderPhase.values[i - 1];
  }
}
