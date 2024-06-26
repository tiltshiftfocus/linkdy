import 'package:dio/dio.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'package:linkdy/constants/enums.dart';
import 'package:linkdy/models/api_response.dart';
import 'package:linkdy/models/data/bookmarks.dart';
import 'package:linkdy/models/data/check_bookmark.dart';
import 'package:linkdy/models/data/patch_bookmark_data.dart';
import 'package:linkdy/models/data/set_bookmark_data.dart';
import 'package:linkdy/models/data/tags.dart';
import 'package:linkdy/models/server_instance.dart';

Future<bool> testServerReachability(String url) async {
  try {
    await Dio(BaseOptions(connectTimeout: const Duration(seconds: 5))).get("$url/api/");
    return true;
  } on DioException catch (e) {
    if (e.response?.statusCode != null) {
      return true;
    }
    return false;
  } catch (e) {
    return false;
  }
}

class ApiClientService {
  final ServerInstance serverInstance;
  final Dio dioInstance;

  const ApiClientService({
    required this.serverInstance,
    required this.dioInstance,
  });

  Future<AuthResult> checkConnectionInstance() async {
    try {
      await dioInstance.get("/bookmarks/?limit=1");
      return AuthResult.success;
    } on DioException catch (e) {
      if (e.response != null && e.response!.statusCode == 401 || e.response!.statusCode == 403) {
        return AuthResult.invalidToken;
      }
      return AuthResult.other;
    } catch (e) {
      return AuthResult.other;
    }
  }

  Future<ApiResponse<BookmarksResponse>> fetchBookmarks({
    String? q,
    int? limit,
    int? offset,
    ReadStatus? unread,
    String? sort,
  }) async {
    try {
      final response = await dioInstance.get(
        "/bookmarks/",
        queryParameters: {
          "q": q,
          "limit": limit,
          "offset": offset,
          "unread": unread == ReadStatus.unread
              ? "yes"
              : unread == ReadStatus.read
                  ? "no"
                  : null,
          "sort": sort,
        },
      );
      if (response.statusCode == null || response.statusCode! >= 400) {
        return const ApiResponse(successful: false);
      }
      return ApiResponse(
        successful: true,
        content: BookmarksResponse.fromJson(response.data),
      );
    } on DioException {
      return const ApiResponse(successful: false);
    } on FormatException catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
      return const ApiResponse(successful: false);
    } catch (_) {
      return const ApiResponse(successful: false);
    }
  }

  Future<ApiResponse<BookmarksResponse>> fetchArchivedBookmarks({String? q, int? limit, int? offset}) async {
    try {
      final response = await dioInstance.get(
        "/bookmarks/archived/",
        queryParameters: {
          "q": q,
          "limit": limit,
          "offset": offset,
        },
      );
      if (response.statusCode != 200) {
        return const ApiResponse(successful: false);
      }
      return ApiResponse(
        successful: true,
        content: BookmarksResponse.fromJson(response.data),
      );
    } on DioException {
      return const ApiResponse(successful: false);
    } on FormatException catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
      return const ApiResponse(successful: false);
    } catch (_) {
      return const ApiResponse(successful: false);
    }
  }

  Future<ApiResponse<BookmarksResponse>> fetchSharedBookmarks({String? q, int? limit, int? offset}) async {
    try {
      final response = await dioInstance.get(
        "/bookmarks/shared/",
        queryParameters: {
          "q": q,
          "limit": limit,
          "offset": offset,
        },
      );
      if (response.statusCode != 200) {
        return const ApiResponse(successful: false);
      }
      return ApiResponse(
        successful: true,
        content: BookmarksResponse.fromJson(response.data),
      );
    } on DioException {
      return const ApiResponse(successful: false);
    } on FormatException catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
      return const ApiResponse(successful: false);
    } catch (_) {
      return const ApiResponse(successful: false);
    }
  }

  Future<ApiResponse<CheckBookmark>> fetchCheckAddBookmark({required String url}) async {
    try {
      final response = await dioInstance.get(
        "/bookmarks/check",
        queryParameters: {
          "url": url,
        },
      );
      if (response.statusCode != 200) {
        return const ApiResponse(successful: false);
      }
      return ApiResponse(
        successful: true,
        content: CheckBookmark.fromJson(response.data),
      );
    } on DioException {
      return const ApiResponse(successful: false);
    } on FormatException catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
      return const ApiResponse(successful: false);
    } catch (_) {
      return const ApiResponse(successful: false);
    }
  }

  Future<ApiResponse<Bookmark>> postBookmark(SetBookmarkData bookmark) async {
    try {
      final response = await dioInstance.post(
        "/bookmarks/",
        data: FormData.fromMap(bookmark.toJson()),
      );
      if (response.statusCode == null || response.statusCode! >= 400) {
        return const ApiResponse(successful: false);
      }
      return ApiResponse(
        successful: true,
        content: Bookmark.fromJson(response.data),
      );
    } on DioException {
      return const ApiResponse(successful: false);
    } on FormatException catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
      return const ApiResponse(successful: false);
    } catch (_) {
      return const ApiResponse(successful: false);
    }
  }

  Future<ApiResponse<TagsResponse>> fetchTags({String? q, int? limit, int? offset}) async {
    try {
      final response = await dioInstance.get(
        "/tags/",
        queryParameters: {
          "q": q,
          "limit": limit,
          "offset": offset,
        },
      );
      if (response.statusCode != 200) {
        return const ApiResponse(successful: false);
      }
      return ApiResponse(
        successful: true,
        content: TagsResponse.fromJson(response.data),
      );
    } on DioException {
      return const ApiResponse(successful: false);
    } on FormatException catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
      return const ApiResponse(successful: false);
    } catch (_) {
      return const ApiResponse(successful: false);
    }
  }

  Future<ApiResponse<Tag>> postTag(String name) async {
    try {
      final response = await dioInstance.post(
        "/tags/",
        data: FormData.fromMap({"name": name}),
      );
      return ApiResponse(
        successful: true,
        content: Tag.fromJson(response.data),
      );
    } on DioException {
      return const ApiResponse(successful: false);
    } on FormatException catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
      return const ApiResponse(successful: false);
    } catch (_) {
      return const ApiResponse(successful: false);
    }
  }

  Future<ApiResponse<Tag>> fetchTagById(String tagId) async {
    try {
      final response = await dioInstance.get("/tags/$tagId/");
      if (response.statusCode != 200) {
        return const ApiResponse(successful: false);
      }
      return ApiResponse(
        successful: true,
        content: Tag.fromJson(response.data),
      );
    } on DioException {
      return const ApiResponse(successful: false);
    } on FormatException catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
      return const ApiResponse(successful: false);
    } catch (_) {
      return const ApiResponse(successful: false);
    }
  }

  Future<ApiResponse<bool>> postDeleteBookmark(int bookmarkId) async {
    try {
      await dioInstance.delete("/bookmarks/$bookmarkId/");
      return const ApiResponse(successful: true);
    } on DioException {
      return const ApiResponse(successful: false);
    } on FormatException catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
      return const ApiResponse(successful: false);
    } catch (_) {
      return const ApiResponse(successful: false);
    }
  }

  Future<ApiResponse<Bookmark>> putUpdateBookmark(int bookmarkId, SetBookmarkData bookmark) async {
    try {
      final result = await dioInstance.put(
        "/bookmarks/$bookmarkId/",
        data: FormData.fromMap(bookmark.toJson()),
      );
      if (result.statusCode == null || result.statusCode! >= 400) {
        return const ApiResponse(successful: false);
      }
      return ApiResponse(
        successful: true,
        content: Bookmark.fromJson(result.data),
      );
    } on DioException {
      return const ApiResponse(successful: false);
    } on FormatException catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
      return const ApiResponse(successful: false);
    } catch (_) {
      return const ApiResponse(successful: false);
    }
  }

  Future<ApiResponse<bool>> postArchiveBookmark(int bookmarkId) async {
    try {
      await dioInstance.post("/bookmarks/$bookmarkId/archive/");
      return const ApiResponse(successful: true);
    } on DioException {
      return const ApiResponse(successful: false);
    } catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
      return const ApiResponse(successful: false);
    }
  }

  Future<ApiResponse<bool>> postUnrchiveBookmark(int bookmarkId) async {
    try {
      await dioInstance.post("/bookmarks/$bookmarkId/unarchive/");
      return const ApiResponse(successful: true);
    } on DioException {
      return const ApiResponse(successful: false);
    } on FormatException catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
      return const ApiResponse(successful: false);
    } catch (_) {
      return const ApiResponse(successful: false);
    }
  }

  Future<ApiResponse<Bookmark>> patchUpdateBookmark(int bookmarkId, PatchBookmarkData bookmark) async {
    try {
      final result = await dioInstance.patch(
        "/bookmarks/$bookmarkId/",
        data: FormData.fromMap(bookmark.toJson()),
      );
      if (result.statusCode != 200) {
        return const ApiResponse(successful: false);
      }
      return ApiResponse(
        successful: true,
        content: Bookmark.fromJson(result.data),
      );
    } on DioException {
      return const ApiResponse(successful: false);
    } on FormatException catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
      return const ApiResponse(successful: false);
    } catch (_) {
      return const ApiResponse(successful: false);
    }
  }
}
