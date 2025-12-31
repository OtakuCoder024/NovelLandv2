// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_progress_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReadingProgressModelAdapter extends TypeAdapter<ReadingProgressModel> {
  @override
  final int typeId = 2;

  @override
  ReadingProgressModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReadingProgressModel(
      id: fields[0] as String,
      novelId: fields[1] as String,
      currentChapterId: fields[2] as String?,
      currentChapterNumber: fields[3] as int,
      lastReadPosition: fields[4] as double,
      lastReadDate: fields[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ReadingProgressModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.novelId)
      ..writeByte(2)
      ..write(obj.currentChapterId)
      ..writeByte(3)
      ..write(obj.currentChapterNumber)
      ..writeByte(4)
      ..write(obj.lastReadPosition)
      ..writeByte(5)
      ..write(obj.lastReadDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReadingProgressModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
