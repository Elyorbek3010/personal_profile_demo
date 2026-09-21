import 'dart:convert';
import 'package:flutter/material.dart';

/// Helper to get the correct ImageProvider whether the avatar is:
/// - A remote URL (http:// or https://)
/// - A base64 data URI (data:image/...)
/// - Null or empty (returns null for fallback initials/icon)
ImageProvider? getAvatarImageProvider(String? avatar) {
  if (avatar == null || avatar.trim().isEmpty) return null;
  final clean = avatar.trim();
  if (clean.startsWith('data:image')) {
    try {
      final base64Str = clean.split(',').last;
      return MemoryImage(base64Decode(base64Str));
    } catch (_) {
      return null;
    }
  }
  if (clean.startsWith('http://') || clean.startsWith('https://')) {
    return NetworkImage(clean);
  }
  return null;
}
