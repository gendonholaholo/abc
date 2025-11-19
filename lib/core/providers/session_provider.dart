import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/employee.dart';
import '../services/hris_api_client.dart';

typedef Credentials = ({String email, String password});

final hrisClientProvider = Provider<HrisApiClient>((ref) => HrisApiClient());

final sessionProvider = StateNotifierProvider<SessionController, SessionState>(
  (ref) => SessionController(ref.read(hrisClientProvider)),
);

class SessionController extends StateNotifier<SessionState> {
  SessionController(this._client) : super(const SessionState.unauthenticated());

  final HrisApiClient _client;

  Future<void> login(Credentials credentials) async {
    state = const SessionState.loading();
    try {
      final employee = await _client.login(
        email: credentials.email,
        password: credentials.password,
      );
      state = SessionState.authenticated(employee);
    } catch (err) {
      state = SessionState.failure('$err');
    }
  }

  void logout() {
    state = const SessionState.unauthenticated();
  }
}

class SessionState {
  const SessionState._({
    required this.status,
    this.employee,
    this.error,
  });

  const SessionState.unauthenticated()
      : this._(status: SessionStatus.unauthenticated);

  const SessionState.loading() : this._(status: SessionStatus.loading);

  const SessionState.authenticated(Employee emp)
      : this._(status: SessionStatus.authenticated, employee: emp);

  const SessionState.failure(String message)
      : this._(status: SessionStatus.failure, error: message);

  final SessionStatus status;
  final Employee? employee;
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
