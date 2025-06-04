// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_quote.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveQuoteAdapter extends TypeAdapter<HiveQuote> {
  @override
  final int typeId = 0;

  @override
  HiveQuote read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveQuote(
      author: fields[0] as String,
      quote: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, HiveQuote obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.author)
      ..writeByte(1)
      ..write(obj.quote);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveQuoteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
