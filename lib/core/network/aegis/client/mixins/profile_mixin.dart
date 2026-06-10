import 'dart:convert';
import 'dart:typed_data';

import 'package:msgpack_dart/msgpack_dart.dart' as msgpack;
import 'package:two_space_app/core/network/aegis/client/aegis_client_base.dart';
import 'package:two_space_app/core/network/aegis/message.dart';
import 'package:two_space_app/core/network/aegis/message_payloads.dart';
import 'package:two_space_app/core/network/aegis/message_type.dart';
import 'package:two_space_app/core/utils/image_utils.dart';

mixin AegisProfileMixin on AegisClientBase {

  Future<ProfileGetResponse> getOwnProfile() async {
    requireAuthenticated();
    final request = ProfileGetRequest();
    final msg = Message.withType(MessageType.profileGet, request.toBytes());
    final response = await sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.profileGetResponse},
    );
    return ProfileGetResponse.fromBytes(response.payload);
  }

  Future<ProfileGetResponse> getProfile({int? userId, String? username}) async {
    requireAuthenticated();
    final request = ProfileGetRequest(userId: userId, username: username);
    final msg = Message.withType(MessageType.profileGet, request.toBytes());
    final response = await sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.profileGetResponse},
    );
    return ProfileGetResponse.fromBytes(response.payload);
  }

  Future<ProfileUpdateResponse> updateProfile({
    String? displayName,
    String? avatarUrl,
    String? bio,
    String? username,
    String? location,
    String? birthDate,
  }) async {
    requireAuthenticated();

    final request = ProfileUpdateRequest(
      displayName: displayName,
      avatarUrl: avatarUrl,
      bio: bio,
      username: username,
      location: location,
      birthDate: birthDate,
    );

    final msg = Message.withType(MessageType.profileUpdate, request.toBytes());
    final response = await sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.profileUpdateResponse},
    );
    return ProfileUpdateResponse.fromBytes(response.payload);
  }

  Future<ProfileUpdateResponse> uploadUserAvatar(
    Uint8List imageBytes, {
    String mimeType = 'image/jpeg',
  }) async {
    var bytesToUpload = imageBytes;

    if (bytesToUpload.length > 1048000) {
      final compressed = ImageUtils.compressImage(bytesToUpload);
      if (compressed != null) {
        bytesToUpload = compressed;
      }
    }

    final dataUrl = 'data:$mimeType;base64,${base64Encode(bytesToUpload)}';
    final result = await addProfileAvatar(dataUrl, makePrimary: true);
    return ProfileUpdateResponse(
      success: result.success,
      message: result.message,
    );
  }

  Future<ProfileAvatarMutationResponse> addProfileAvatar(
    String avatarUrl, {
    bool makePrimary = false,
  }) async {
    requireAuthenticated();
    final request = ProfileAvatarAddRequest(
      avatarUrl: avatarUrl,
      makePrimary: makePrimary,
    );
    final msg = Message.withType(
      MessageType.profileAvatarAdd,
      request.toBytes(),
    );
    final response = await sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.profileAvatarAddResponse},
    );
    return ProfileAvatarMutationResponse.fromBytes(response.payload);
  }

  Future<ProfileAvatarListResponse> listProfileAvatars() async {
    requireAuthenticated();
    final msg = Message.withType(
      MessageType.profileAvatarList,
      msgpack.serialize(<String, Object?>{}),
    );
    final response = await sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.profileAvatarListResponse},
    );
    return ProfileAvatarListResponse.fromBytes(response.payload);
  }

  Future<ProfileAvatarMutationResponse> deleteProfileAvatar(
    int avatarId,
  ) async {
    requireAuthenticated();
    final request = ProfileAvatarDeleteRequest(avatarId: avatarId);
    final msg = Message.withType(
      MessageType.profileAvatarDelete,
      request.toBytes(),
    );
    final response = await sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.profileAvatarDeleteResponse},
    );
    return ProfileAvatarMutationResponse.fromBytes(response.payload);
  }

  Future<ProfileAvatarMutationResponse> setPrimaryProfileAvatar(
    int avatarId,
  ) async {
    requireAuthenticated();
    final request = ProfileAvatarSetPrimaryRequest(avatarId: avatarId);
    final msg = Message.withType(
      MessageType.profileAvatarSetPrimary,
      request.toBytes(),
    );
    final response = await sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.profileAvatarSetPrimaryResponse},
    );
    return ProfileAvatarMutationResponse.fromBytes(response.payload);
  }

  Future<UserSearchResponse> searchUsers(String query, {int limit = 20}) async {
    requireAuthenticated();

    final request = UserSearchRequest(query: query, limit: limit);
    final msg = Message.withType(MessageType.userSearch, request.toBytes());
    final response = await sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.userSearchResult},
    );
    return UserSearchResponse.fromBytes(response.payload);
  }
}
