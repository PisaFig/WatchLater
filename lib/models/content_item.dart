import 'package:hive/hive.dart';

class ContentItem {
  final String id;
  final String title;
  final String description;
  final String posterUrl;
  final String trailerYoutubeId;
  final String contentType;
  final List<String> genres;
  final double rating;
  final String year;
  final String duration;
  bool isSaved;
  bool isWatched;

  ContentItem({
    required this.id,
    required this.title,
    required this.description,
    required this.posterUrl,
    required this.trailerYoutubeId,
    required this.contentType,
    required this.genres,
    required this.rating,
    required this.year,
    required this.duration,
    this.isSaved = false,
    this.isWatched = false,
  });

  ContentItem copyWith({bool? isSaved, bool? isWatched}) {
    return ContentItem(
      id: id,
      title: title,
      description: description,
      posterUrl: posterUrl,
      trailerYoutubeId: trailerYoutubeId,
      contentType: contentType,
      genres: genres,
      rating: rating,
      year: year,
      duration: duration,
      isSaved: isSaved ?? this.isSaved,
      isWatched: isWatched ?? this.isWatched,
    );
  }
}

// Manual Hive TypeAdapter (avoids build_runner code generation)
class ContentItemAdapter extends TypeAdapter<ContentItem> {
  @override
  final int typeId = 0;

  @override
  ContentItem read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numFields; i++) reader.readByte(): reader.read(),
    };
    return ContentItem(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      posterUrl: fields[3] as String,
      trailerYoutubeId: fields[4] as String,
      contentType: fields[5] as String,
      genres: (fields[6] as List).cast<String>(),
      rating: fields[7] as double,
      year: fields[8] as String,
      duration: fields[9] as String,
      isSaved: fields[10] as bool,
      isWatched: fields[11] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, ContentItem obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.posterUrl)
      ..writeByte(4)
      ..write(obj.trailerYoutubeId)
      ..writeByte(5)
      ..write(obj.contentType)
      ..writeByte(6)
      ..write(obj.genres)
      ..writeByte(7)
      ..write(obj.rating)
      ..writeByte(8)
      ..write(obj.year)
      ..writeByte(9)
      ..write(obj.duration)
      ..writeByte(10)
      ..write(obj.isSaved)
      ..writeByte(11)
      ..write(obj.isWatched);
  }
}
