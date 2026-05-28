import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/api/api_client.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String fullName;

  const AuthRegisterRequested({
    required this.email,
    required this.password,
    required this.fullName,
  });

  @override
  List<Object?> get props => [email, password, fullName];
}

class AuthLogoutRequested extends AuthEvent {}

class AuthOnboardingCompleted extends AuthEvent {
  final String fullName;
  final String language;
  final String theme;

  const AuthOnboardingCompleted({
    required this.fullName,
    required this.language,
    required this.theme,
  });

  @override
  List<Object?> get props => [fullName, language, theme];
}

// States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final Map<String, dynamic> user;

  const AuthAuthenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthNeedsOnboarding extends AuthState {
  final Map<String, dynamic> user;

  const AuthNeedsOnboarding({required this.user});

  @override
  List<Object?> get props => [user];
}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ApiClient apiClient;
  final FlutterSecureStorage storage;

  AuthBloc({required this.apiClient, required this.storage})
      : super(AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthOnboardingCompleted>(_onOnboardingCompleted);
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final isLoggedIn = await apiClient.isLoggedIn();

      if (isLoggedIn) {
        // Get user data from storage
        final response = await apiClient.getProfile();

        if (response.data['success']) {
          final user = response.data['data'];

          if (!user['onboarding_completed']) {
            emit(AuthNeedsOnboarding(user: user));
          } else {
            emit(AuthAuthenticated(user: user));
          }
        } else {
          await apiClient.logout();
          emit(AuthUnauthenticated());
        }
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final response = await apiClient.login(event.email, event.password);

      if (response.data['success']) {
        final data = response.data['data'];

        await apiClient.saveTokens(data['accessToken'], data['refreshToken']);

        final user = data['user'];

        if (!user['onboarding_completed']) {
          emit(AuthNeedsOnboarding(user: user));
        } else {
          emit(AuthAuthenticated(user: user));
        }
      } else {
        emit(AuthError(message: response.data['message'] ?? 'Error de login'));
      }
    } catch (e) {
      debugPrint('Login error: $e');
      String errorMessage = 'Error de conexión';
      if (e.toString().contains('SocketException')) {
        errorMessage = 'No se puede conectar al servidor';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Tiempo de espera agotado';
      }
      emit(AuthError(message: errorMessage));
    }
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      debugPrint('Register request to: ${apiClient.login.toString()}');
      final response = await apiClient.register(
        event.email,
        event.password,
        event.fullName,
      );

      if (response.data['success']) {
        final data = response.data['data'];

        await apiClient.saveTokens(data['accessToken'], data['refreshToken']);

        emit(AuthNeedsOnboarding(user: data['user']));
      } else {
        emit(
          AuthError(message: response.data['message'] ?? 'Error de registro'),
        );
      }
    } catch (e) {
      debugPrint('Register error: $e');
      String errorMessage = 'Error de conexión';
      if (e.toString().contains('SocketException')) {
        errorMessage = 'No se puede conectar al servidor';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Tiempo de espera agotado';
      }
      emit(AuthError(message: errorMessage));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      await apiClient.logout();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onOnboardingCompleted(
    AuthOnboardingCompleted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      await apiClient.completeOnboarding(
        event.fullName,
        event.language,
        event.theme,
      );

      final response = await apiClient.getProfile();

      if (response.data['success']) {
        emit(AuthAuthenticated(user: response.data['data']));
      } else {
        emit(AuthError(message: 'Error al completar onboarding'));
      }
    } catch (e) {
      emit(AuthError(message: 'Error de conexión'));
    }
  }
}
