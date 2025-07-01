// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      uid: json['uid'] as String,
      username: json['username'] as String,
      hashedPassword: json['hashed_password'] as String,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'uid': instance.uid,
      'username': instance.username,
      'hashed_password': instance.hashedPassword,
    };

Token _$TokenFromJson(Map<String, dynamic> json) => Token(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      tokenType: json['token_type'] as String,
    );

Map<String, dynamic> _$TokenToJson(Token instance) => <String, dynamic>{
      'access_token': instance.accessToken,
      'refresh_token': instance.refreshToken,
      'token_type': instance.tokenType,
    };

TokenRefreshRequest _$TokenRefreshRequestFromJson(Map<String, dynamic> json) =>
    TokenRefreshRequest(
      refreshToken: json['refresh_token'] as String,
    );

Map<String, dynamic> _$TokenRefreshRequestToJson(
        TokenRefreshRequest instance) =>
    <String, dynamic>{
      'refresh_token': instance.refreshToken,
    };

UserCreate _$UserCreateFromJson(Map<String, dynamic> json) => UserCreate(
      username: json['username'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$UserCreateToJson(UserCreate instance) =>
    <String, dynamic>{
      'username': instance.username,
      'password': instance.password,
    };

WechatLoginRequest _$WechatLoginRequestFromJson(Map<String, dynamic> json) =>
    WechatLoginRequest(
      code: json['code'] as String,
      encryptedData: json['encryptedData'] as String,
      iv: json['iv'] as String,
    );

Map<String, dynamic> _$WechatLoginRequestToJson(WechatLoginRequest instance) =>
    <String, dynamic>{
      'code': instance.code,
      'encryptedData': instance.encryptedData,
      'iv': instance.iv,
    };

OAuth2LoginRequest _$OAuth2LoginRequestFromJson(Map<String, dynamic> json) =>
    OAuth2LoginRequest(
      grantType: json['grant_type'] as String?,
      username: json['username'] as String,
      password: json['password'] as String,
      scope: json['scope'] as String?,
      clientId: json['client_id'] as String?,
      clientSecret: json['client_secret'] as String?,
    );

Map<String, dynamic> _$OAuth2LoginRequestToJson(OAuth2LoginRequest instance) =>
    <String, dynamic>{
      'grant_type': instance.grantType,
      'username': instance.username,
      'password': instance.password,
      'scope': instance.scope,
      'client_id': instance.clientId,
      'client_secret': instance.clientSecret,
    };
