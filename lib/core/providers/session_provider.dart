import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/auth_session.dart';
import '../models/employee.dart';
import '../services/hris_api_client.dart';
import '../storage/local_store.dart';

typedef Credentials = ({String email, String password});

final hrisClientProvider = Provider<HrisApiClient>((ref) => HrisApiClient());
final localStoreProvider = Provider<LocalStore>((_) => LocalStore());

final sessionProvider = StateNotifierProvider<SessionController, SessionState>(
  (ref) => SessionController(
    ref.read(hrisClientProvider),
    ref.read(localStoreProvider),
  ),
);

class SessionController extends StateNotifier<SessionState> {
  SessionController(this._client, this._store)
      : super(const SessionState.unauthenticated()) {
    _restoreSession();
  }

  final HrisApiClient _client;
  final LocalStore _store;

  Future<void> login(Credentials credentials) async {
    state = const SessionState.loading();
    try {
      final auth = await _client.login(
        email: credentials.email,
        password: credentials.password,
      );
      _client.updateAuthToken(auth.token);
      await _store.persistSession(token: auth.token, employee: auth.employee);
      state = SessionState.authenticated(auth.employee, auth.token);
    } catch (err) {
      state = SessionState.failure('$err');
    }
  }

  Future<void> _restoreSession() async {
    final restored = await _store.restoreSession();
    if (restored == null) return;
    _client.updateAuthToken(restored.$1);
    state = SessionState.authenticated(restored.$2, restored.$1);
  }

  Future<void> logout() async {
    await _store.clearSession();
    _client.updateAuthToken(null);
    state = const SessionState.unauthenticated();
  }
}

class SessionState {
  const SessionState._({
    required this.status,
    this.employee,
    this.token,
    this.error,
  });

  const SessionState.unauthenticated()
      : this._(status: SessionStatus.unauthenticated);

  const SessionState.loading() : this._(status: SessionStatus.loading);

  const SessionState.authenticated(Employee emp, String token)
      : this._(status: SessionStatus.authenticated, employee: emp, token: token);

  const SessionState.failure(String message)
      : this._(status: SessionStatus.failure, error: message);

  final SessionStatus status;
  final Employee? employee;
  final String? token;
  final String? error;

  T? whenOrNull<T>({
    T Function()? unauthenticated,
    T Function()? loading,
    T Function(Employee employee)? authenticated,
    T Function(String message)? failure,
  }) {
    switch (status) {
      case SessionStatus.unauthenticated:
        return unauthenticated?.call();
      case SessionStatus.loading:
        return loading?.call();
      case SessionStatus.authenticated:
        return authenticated?.call(employee!);
      case SessionStatus.failure:
        return failure?.call(error ?? 'Unknown error');
    }
  }

  T maybeWhen<T>({
    required T Function() orElse,
    T Function()? unauthenticated,
    T Function()? loading,
    T Function(Employee employee)? authenticated,
    T Function(String message)? failure,
  }) {
    return whenOrNull(
          unauthenticated: unauthenticated,
          loading: loading,
          authenticated: authenticated,
          failure: failure,
        ) ??
        orElse();
  }
}

enum SessionStatus { unauthenticated, loading, authenticated, failure }
