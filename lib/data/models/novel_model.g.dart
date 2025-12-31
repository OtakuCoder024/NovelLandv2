// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'novel_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NovelModelAdapter extends TypeAdapter<NovelModel> {
  @override
  final int typeId = 0;

  @override
  NovelModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NovelModel(
      id: fields[0] as String,
      title: fields[1] as String,
      author: fields[2] as String,
      description: fields[3] as String,
      coverUrl: fields[4] as String,
      sourceUrl: fields[5] as String,
      sourceName: fields[6] as String,
      genres: (fields[7] as List).cast<String>(),
      status: fields[8] as String?,
      lastUpdated: fields[9] as DateTime?,
      totalChapters: fields[10] as int?,
      isDownloaded: fields[11] as bool,
      downloadPath: fields[12] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, NovelModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.author)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.coverUrl)
      ..writeByte(5)
      ..write(obj.sourceUrl)
      ..writeByte(6)
      ..write(obj.sourceName)
      ..writeByte(7)
      ..write(obj.genres)
      ..writeByte(8)
      ..write(obj.status)
      ..writeByte(9)
      ..write(obj.lastUpdated)
      ..writeByte(10)
      ..write(obj.totalChapters)
      ..writeByte(11)
      ..write(obj.isDownloaded)
      ..writeByte(12)
      ..write(obj.downloadPath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NovelModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
