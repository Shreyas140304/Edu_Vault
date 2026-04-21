// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entrance_exam_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EntranceExamAdapter extends TypeAdapter<EntranceExam> {
  @override
  final int typeId = 2;

  @override
  EntranceExam read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EntranceExam(
      id: fields[0] as String?,
      examName: fields[1] as String?,
      applicationDeadline: fields[2] as DateTime?,
      examDate: fields[3] as DateTime?,
      requiredDocuments: (fields[4] as List?)?.cast<String>(),
      uploadedDocumentIds: (fields[5] as List?)?.cast<String>(),
      examLink: fields[6] as String?,
      officialPortal: fields[7] as String?,
      lastUpdated: fields[8] as DateTime?,
      notes: fields[9] as String?,
      isActive: fields[10] as bool?,
      applicationStatus: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, EntranceExam obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.examName)
      ..writeByte(2)
      ..write(obj.applicationDeadline)
      ..writeByte(3)
      ..write(obj.examDate)
      ..writeByte(4)
      ..write(obj.requiredDocuments)
      ..writeByte(5)
      ..write(obj.uploadedDocumentIds)
      ..writeByte(6)
      ..write(obj.examLink)
      ..writeByte(7)
      ..write(obj.officialPortal)
      ..writeByte(8)
      ..write(obj.lastUpdated)
      ..writeByte(9)
      ..write(obj.notes)
      ..writeByte(10)
      ..write(obj.isActive)
      ..writeByte(11)
      ..write(obj.applicationStatus);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EntranceExamAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
