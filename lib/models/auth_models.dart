import 'package:json_annotation/json_annotation.dart';

part 'auth_models.g.dart';

@JsonSerializable()
class User {
  final String uid;
  final String username;
  @JsonKey(name: 'hashed_password')
  final String hashedPassword;

  User({
    required this.uid,
    required this.username,
    required this.hashedPassword,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable()
class Token {
  @JsonKey(name: 'access_token')
  final String accessToken;
  @JsonKey(name: 'refresh_token')
  final String refreshToken;
  @JsonKey(name: 'token_type')
  final String tokenType;

  Token({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
  });

  factory Token.fromJson(Map<String, dynamic> json) => _$TokenFromJson(json);
  Map<String, dynamic> toJson() => _$TokenToJson(this);
}

@JsonSerializable()
class TokenRefreshRequest {
  @JsonKey(name: 'refresh_token')
  final String refreshToken;

  TokenRefreshRequest({required this.refreshToken});

  factory TokenRefreshRequest.fromJson(Map<String, dynamic> json) =>
      _$TokenRefreshRequestFromJson(json);
  Map<String, dynamic> toJson() => _$TokenRefreshRequestToJson(this);
}

@JsonSerializable()
class UserCreate {
  final String username;
  final String password;

  UserCreate({
    required this.username,
    required this.password,
  });

  factory UserCreate.fromJson(Map<String, dynamic> json) =>
      _$UserCreateFromJson(json);
  Map<String, dynamic> toJson() => _$UserCreateToJson(this);
}

@JsonSerializable()
class WechatLoginRequest {
  final String code;
  final String encryptedData;
  final String iv;

  WechatLoginRequest({
    required this.code,
    required this.encryptedData,
    required this.iv,
  });

  factory WechatLoginRequest.fromJson(Map<String, dynamic> json) =>
      _$WechatLoginRequestFromJson(json);
  Map<String, dynamic> toJson() => _$WechatLoginRequestToJson(this);
}

@JsonSerializable()
class OAuth2LoginRequest {
  @JsonKey(name: 'grant_type')
  final String? grantType;
  final String username;
  final String password;
  final String? scope;
  @JsonKey(name: 'client_id')
  final String? clientId;
  @JsonKey(name: 'client_secret')
  final String? clientSecret;

  OAuth2LoginRequest({
    this.grantType,
    required this.username,
    required this.password,
    this.scope,
    this.clientId,
    this.clientSecret,
  });

  factory OAuth2LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$OAuth2LoginRequestFromJson(json);
  Map<String, dynamic> toJson() => _$OAuth2LoginRequestToJson(this);
} 