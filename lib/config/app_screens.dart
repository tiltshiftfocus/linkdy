import 'package:flutter/material.dart';

import 'package:linkdy/i18n/strings.g.dart';
import 'package:linkdy/models/app_route.dart';
import 'package:linkdy/router/paths.dart';

final appScreens = [
  AppRoute(
    icon: Icons.bookmarks_rounded,
    route: RoutesPaths.links,
    name: t.bookmarks.bookmarks,
  ),
  AppRoute(
    icon: Icons.search_rounded,
    route: RoutesPaths.search,
    name: t.search.search,
  ),
  AppRoute(
    icon: Icons.settings_rounded,
    route: RoutesPaths.settings,
    name: t.settings.settings,
  ),
];
