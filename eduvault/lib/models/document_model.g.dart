// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DocumentAdapter extends TypeAdapter<Document> {
  @override
  final int typeId = 1;

  @override
  Document read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Document(
      id: fields[0] as String?,
      fileName: fields[1] as String?,
      filePath: fields[2] as String?,
      fileType: fields[3] as String?,
      fileSize: fields[4] as int?,
      stage: fields[5] as String?,
      category: fields[6] as String?,
      extractedText: fields[7] as String?,
      detectionConfidence: fields[8] as String?,
      tags: (fields[9] as List?)?.cast<String>(),
      uploadedAt: fields[10] as DateTime?,
      scannedAt: fields[11] as DateTime?,
      isRequired: fields[12] as bool?,
      relatedExam: fields[13] as String?,
      isFavorite: fields[14] as bool?,
      notes: fields[15] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Document obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.fileName)
      ..writeByte(2)
      ..write(obj.filePath)
      ..writeByte(3)
      ..write(obj.fileType)
      ..writeByte(4)
      ..write(obj.fileSize)
      ..writeByte(5)
      ..write(obj.stage)
      ..writeByte(6)
      ..write(obj.category)
      ..writeByte(7)
      ..write(obj.extractedText)
      ..writeByte(8)
      ..write(obj.detectionConfidence)
      ..writeByte(9)
      ..write(obj.tags)
      ..writeByte(10)
      ..write(obj.uploadedAt)
      ..writeByte(11)
      ..write(obj.scannedAt)
      ..writeByte(12)
      ..write(obj.isRequired)
      ..writeByte(13)
      ..write(obj.relatedExam)
      ..writeByte(14)
      ..write(obj.isFavorite)
      ..writeByte(15)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DocumentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
