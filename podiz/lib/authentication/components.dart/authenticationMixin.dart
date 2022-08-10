import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/failures/errorBar.dart';
import 'package:podiz/aspect/failures/failure.dart';
import 'package:podiz/authentication/authManager.dart';
import 'package:podiz/providers.dart';

mixin Authentication<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  bool _isLoading = false;

  Future<void> authenticate(
    Future<void> Function(AuthManager authManager) signIn, {
    GlobalKey<FormState>? formKey,
  }) async {
    if (_isLoading) return;
    _isLoading = true;
    try {
      FocusScope.of(context).unfocus();
      await _checkConnection();

      if (formKey != null) {
        final isValid = formKey.currentState!.validate();
        if (!isValid) {
          _isLoading = false;
          return;
        }
      }

      final authManager = ref.read(authManagerProvider);
      await signIn(authManager);
    } on Failure catch (e) {
      showErrorBar(context, e.message);
    }
    _isLoading = false;
  }

  Future<void> _checkConnection() async {
    final connectivity = await ref.read(connectivityProvider.future);
    if (mounted && connectivity == ConnectivityResult.none) {
      throw Failure.noConection(context);
    }
  }
}
