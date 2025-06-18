// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gasto.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GastoAdapter extends TypeAdapter<Gasto> {
  @override
  final int typeId = 0;

  @override
  Gasto read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Gasto(
      cantidad: fields[0] as double,
      titulo: fields[7] as String?,
      moneda: fields[1] as String,
      fecha: fields[2] as DateTime,
      tiempoTrabajo: fields[3] as int,
      descripcion: fields[4] as String?,
      categoria: fields[5] as String?,
      configSnapshot: (fields[6] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, Gasto obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.cantidad)
      ..writeByte(1)
      ..write(obj.moneda)
      ..writeByte(2)
      ..write(obj.fecha)
      ..writeByte(3)
      ..write(obj.tiempoTrabajo)
      ..writeByte(4)
      ..write(obj.descripcion)
      ..writeByte(5)
      ..write(obj.categoria)
      ..writeByte(6)
      ..write(obj.configSnapshot)
      ..writeByte(7)
      ..write(obj.titulo);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GastoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
