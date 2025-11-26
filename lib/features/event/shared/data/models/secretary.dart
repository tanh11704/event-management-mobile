import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'secretary.g.dart';

@JsonSerializable(createToJson: false)
class SecretaryInfo extends Equatable {
  const SecretaryInfo({
    required this.userId,
    required this.userName,
    this.userEmail,
  });

  factory SecretaryInfo.fromJson(Map<String, dynamic> json) =>
      _$SecretaryInfoFromJson(json);

  @JsonKey(name: 'user_id')
  final int userId;

  @JsonKey(name: 'user_name')
  final String userName;

  @JsonKey(name: 'user_email')
  final String? userEmail;

  @override
  List<Object?> get props => [userId, userName, userEmail];
}
