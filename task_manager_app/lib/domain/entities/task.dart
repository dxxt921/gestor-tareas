enum TaskPriority {
  alta('alta'),
  media('media'),
  baja('baja');

  final String value;
  const TaskPriority(this.value);

  static TaskPriority fromString(String value) {
    return TaskPriority.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TaskPriority.media,
    );
  }
}

enum TaskState {
  pendiente('pendiente'),
  enProgreso('en progreso'),
  hecha('hecha');

  final String value;
  const TaskState(this.value);

  static TaskState fromString(String value) {
    return TaskState.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TaskState.pendiente,
    );
  }
}

class Task {
  final int? id;
  final int? userId;
  final String titulo;
  final String? descripcion;
  final TaskPriority prioridad;
  final TaskState estado;
  final DateTime? fechaCreacion;
  final DateTime? fechaLimite;
  final DateTime? updatedAt;

  Task({
    this.id,
    this.userId,
    required this.titulo,
    this.descripcion,
    this.prioridad = TaskPriority.media,
    this.estado = TaskState.pendiente,
    this.fechaCreacion,
    this.fechaLimite,
    this.updatedAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as int?,
      userId: json['user_id'] as int?,
      titulo: json['titulo'] as String,
      descripcion: json['descripcion'] as String?,
      prioridad:
          TaskPriority.fromString(json['prioridad'] as String? ?? 'media'),
      estado: TaskState.fromString(json['estado'] as String? ?? 'pendiente'),
      fechaCreacion: json['fecha_creacion'] != null
          ? DateTime.parse(json['fecha_creacion'] as String)
          : null,
      fechaLimite: json['fecha_limite'] != null
          ? DateTime.parse(json['fecha_limite'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      'titulo': titulo,
      'descripcion': descripcion,
      'prioridad': prioridad.value,
      'estado': estado.value,
      if (fechaLimite != null)
        'fecha_limite': fechaLimite!.toIso8601String().split('T')[0],
    };
  }

  Task copyWith({
    int? id,
    int? userId,
    String? titulo,
    String? descripcion,
    TaskPriority? prioridad,
    TaskState? estado,
    DateTime? fechaCreacion,
    DateTime? fechaLimite,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      prioridad: prioridad ?? this.prioridad,
      estado: estado ?? this.estado,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaLimite: fechaLimite ?? this.fechaLimite,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
