import 'package:json_annotation/json_annotation.dart';

part 'image_upload_response.g.dart';

@JsonSerializable()
class ImageUploadResponse {
  ImageUploadResponse({required this.url});

  factory ImageUploadResponse.fromJson(Map<String, dynamic> json) =>
      _$ImageUploadResponseFromJson(json);

  @JsonKey(name: 'url')
  final String url;

  Map<String, dynamic> toJson() => _$ImageUploadResponseToJson(this);
}
