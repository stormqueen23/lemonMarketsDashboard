import 'package:json_annotation/json_annotation.dart';
import 'package:lemon_markets_client/lemon_markets_client.dart';

part 'authData.g.dart';

@JsonSerializable()
class AuthData {
  @JsonKey()
  String clientId;
  @JsonKey()
  String clientSecret;

  @JsonKey()
  String? spaceUuid;
  @JsonKey()
  String? spaceName;

  @JsonKey()
  AccessToken? token;
  @JsonKey()
  DateTime? tokenExpireDate;

  AuthData(this.clientId, this.clientSecret);

  factory AuthData.fromJson(Map<String, dynamic> json) => _$AuthDataFromJson(json);

  Map<String, dynamic> toJson() => _$AuthDataToJson(this);

  @override
  bool operator ==(Object other) => identical(this, other) || other is AuthData && runtimeType == other.runtimeType && clientId == other.clientId;

  @override
  int get hashCode => clientId.hashCode;

}
