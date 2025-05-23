import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:linkdy/screens/bookmarks/provider/bookmarks.provider.dart';
import 'package:linkdy/screens/bookmarks/model/bookmark_form.model.dart';

import 'package:linkdy/providers/app_status.provider.dart';
import 'package:linkdy/constants/global_keys.dart';
import 'package:linkdy/models/data/bookmarks.dart';
import 'package:linkdy/utils/snackbar.dart';
import 'package:linkdy/models/data/tags.dart';
import 'package:linkdy/i18n/strings.g.dart';
import 'package:linkdy/utils/process_modal.dart';
import 'package:linkdy/models/data/set_bookmark_data.dart';
import 'package:linkdy/providers/router.provider.dart';
import 'package:linkdy/constants/enums.dart';
import 'package:linkdy/constants/regexp.dart';
import 'package:linkdy/models/api_response.dart';
import 'package:linkdy/models/data/check_bookmark.dart';
import 'package:linkdy/providers/api_client.provider.dart';

part 'bookmark_form.provider.g.dart';

@riverpod
Future<ApiResponse<CheckBookmark>> checkBookmark(CheckBookmarkRef ref, String url) async {
  final result = await ref.watch(apiClientProvider)!.fetchCheckAddBookmark(url: url);
  return result;
}

@riverpod
FutureOr<ApiResponse<TagsResponse>> getTags(GetTagsRef ref) async {
  final result = await ref.watch(apiClientProvider)!.fetchTags();
  return result;
}

@riverpod
class BookmarkForm extends _$BookmarkForm {
  @override
  BookmarkFormModel build() {
    return BookmarkFormModel(
      urlController: TextEditingController(),
      titleController: TextEditingController(),
      descriptionController: TextEditingController(),
      tagsController: TextEditingController(),
      tags: [],
      notesController: TextEditingController(),
      markAsUnread: ref.read(appStatusProvider).markAsUnreadDefault,
    );
  }

  void initializeProvider(Bookmark bookmark) {
    state.editBookmarkId = bookmark.id;
    state.bookmarkValid = true;
    state.checkBookmarkLoadStatus = LoadStatus.loaded;
    state.urlController.text = bookmark.url ?? '';
    state.titleController.text = bookmark.title ?? '';
    state.descriptionController.text = bookmark.description ?? '';
    state.tags = bookmark.tagNames ?? [];
    state.notesController.text = bookmark.notes ?? '';
    state.markAsUnread = bookmark.unread ?? ref.read(appStatusProvider).markAsUnreadDefault;
    state.share = bookmark.shared ?? false;
  }

  void initializeProviderUrl(String url) {
    try {
      final decoded = Uri.decodeComponent(url);
      var value = decoded.contains(":~:text=") ? decoded.split(":~:text=")[1] : null;
      state.urlController.text = value ?? decoded;
      if (Regexps.urlWithoutProtocol.hasMatch(value ?? decoded)) {
        state.urlError = null;
        checkUrlDetails(updateState: false);
      } else {
        state.urlError = t.bookmarks.addBookmark.invalidUrl;
      }
    } catch (e) {
      state.urlController.text = url;
      state.urlError = t.bookmarks.addBookmark.invalidUrl;
      ref.notifyListeners();
    }
  }

  void validateUrl(String value) {
    state.bookmarkValid = null;
    state.checkBookmarkLoadStatus = null;
    if (Regexps.urlWithoutProtocol.hasMatch(value)) {
      state.urlError = null;
      ref.notifyListeners();
    } else {
      state.urlError = t.bookmarks.addBookmark.invalidUrl;
      ref.notifyListeners();
    }
  }

  void checkUrlDetails({required bool updateState}) async {
    if (state.urlError == null && state.urlController.text != "") {
      state.checkBookmarkLoadStatus = LoadStatus.loading;
      state.bookmarkValid = null;
      if (updateState == true) {
        ref.notifyListeners();
      }
      final result = await ref.read(checkBookmarkProvider(state.urlController.text).future);
      if (result.successful == true) {
        if (result.content?.bookmark != null) {
          state.titleController.text = result.content?.bookmark?.title ?? "";
          state.descriptionController.text = result.content?.metadata?.description ?? "";
          state.tags = result.content?.bookmark?.tagNames ?? [];
          state.notesController.text = result.content?.bookmark?.notes ?? "";
          state.markAsUnread = result.content?.bookmark?.unread ?? ref.read(appStatusProvider).markAsUnreadDefault;
          state.share = result.content?.bookmark?.shared ?? false;
          state.bookmarkExists = true;
        } else {
          state.titleController.text = result.content?.metadata?.title ?? "";
          state.descriptionController.text = result.content?.metadata?.description ?? "";
        }
        state.bookmarkValid = true;
        state.checkBookmarkLoadStatus = LoadStatus.loaded;
      } else {
        state.checkBookmarkLoadStatus = LoadStatus.error;
      }
      ref.notifyListeners();
    }
  }

  void updateMarkAsUnread(bool value) {
    state.markAsUnread = value;
    ref.notifyListeners();
  }

  void updateShare(bool value) {
    state.share = value;
    ref.notifyListeners();
  }

  void saveBookmark() async {
    final newBookmark = SetBookmarkData(
      url: state.urlController.text,
      title: state.titleController.text,
      description: state.descriptionController.text,
      isArchived: false,
      unread: state.markAsUnread,
      shared: state.share,
      tagNames: state.tags.join(","),
      notes: state.notesController.text,
    );

    final processModal = ProcessModal();
    processModal.open(t.bookmarks.addBookmark.savingBookmark);

    final result = state.editBookmarkId != null
        ? await ref.watch(apiClientProvider)!.putUpdateBookmark(state.editBookmarkId!, newBookmark)
        : await ref.watch(apiClientProvider)!.postBookmark(newBookmark);

    processModal.close();

    if (result.successful == true) {
      ref.read(bookmarksProvider.notifier).refresh();
      ref.watch(routerProvider).pop();
      showSnackbar(
        key: ScaffoldMessengerKeys.bookmarks,
        label: t.bookmarks.addBookmark.bookmarkSavedSuccessfully,
        color: Colors.green,
      );
    } else {
      showSnackbar(
        key: ScaffoldMessengerKeys.addBookmark,
        label: t.bookmarks.addBookmark.errorSavingBookmark,
        color: Colors.red,
      );
    }
  }

  void validateTagInput(String value) {
    if (value.contains(" ")) {
      state.tagsError = t.bookmarks.addBookmark.tagNoWhitespaces;
    } else {
      state.tagsError = null;
    }
    ref.notifyListeners();
  }

  void setTags(List<String> tags) {
    state.tags = tags;
    ref.notifyListeners();
  }

  void clearTagsController() {
    state.tagsController.clear();
    ref.notifyListeners();
  }
}
