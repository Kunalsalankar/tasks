import 'dart:async';
import 'package:flutter/material.dart';

class SearchService {
  // Debounce duration for search feature
  final Duration debounceDuration;
  Timer? _debounceTimer;

  // Constructor with optional debounce duration
  SearchService({this.debounceDuration = const Duration(milliseconds: 500)});

  /// Performs a debounced search using the provided search function
  ///
  /// Takes a search query string and a callback function that will be called
  /// after the debounce duration if no additional search requests are made.
  /// This prevents excessive function calls during rapid typing.
  void debounceSearch(String query, Function(String) searchFunction) {
    // Cancel existing timer if any
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
    }

    // Create a new timer
    _debounceTimer = Timer(debounceDuration, () {
      searchFunction(query);
    });
  }

  // Cleanup resources
  void dispose() {
    _debounceTimer?.cancel();
  }
}

// Enum for task list sort options
enum SortOption {
  dateAscending,
  dateDescending,
  titleAZ,
  titleZA,
  priorityHighToLow,
  priorityLowToHigh
}

// Extension to get display name for sort options
extension SortOptionExtension on SortOption {
  String get displayName {
    switch (this) {
      case SortOption.dateAscending:
        return 'Date (Oldest first)';
      case SortOption.dateDescending:
        return 'Date (Newest first)';
      case SortOption.titleAZ:
        return 'Title (A-Z)';
      case SortOption.titleZA:
        return 'Title (Z-A)';
      case SortOption.priorityHighToLow:
        return 'Priority (High to Low)';
      case SortOption.priorityLowToHigh:
        return 'Priority (Low to High)';
    }
  }

  IconData get icon {
    switch (this) {
      case SortOption.dateAscending:
        return Icons.arrow_upward;
      case SortOption.dateDescending:
        return Icons.arrow_downward;
      case SortOption.titleAZ:
        return Icons.sort_by_alpha;
      case SortOption.titleZA:
        return Icons.sort_by_alpha;
      case SortOption.priorityHighToLow:
        return Icons.priority_high;
      case SortOption.priorityLowToHigh:
        return Icons.low_priority;
    }
  }
}