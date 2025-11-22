import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swardenapp/app/domain/repos/auth_repo.dart';
import 'package:swardenapp/app/domain/repos/entries_repo.dart';

// Casos d'ús d'autenticació
import 'auth/sign_in_use_case.dart';
import 'auth/register_user_use_case.dart';
import 'auth/sign_out_use_case.dart';
import 'auth/get_current_user_use_case.dart';
import 'auth/delete_account_use_case.dart';

// Casos d'ús d'entrades
import 'entries/get_user_entries_use_case.dart';
import 'entries/create_entry_use_case.dart';
import 'entries/update_entry_use_case.dart';
import 'entries/delete_entry_use_case.dart';
import 'entries/unlock_vault_use_case.dart';

// Proveïdors dels casos d'ús d'autenticació -------------------

final signInUseCaseProvider = Provider<SignInUseCase>(
  (ref) => SignInUseCase(ref.watch(authRepoProvider)),
);

final registerUserUseCaseProvider = Provider<RegisterUserUseCase>(
  (ref) => RegisterUserUseCase(ref.watch(authRepoProvider)),
);

final signOutUseCaseProvider = Provider<SignOutUseCase>(
  (ref) => SignOutUseCase(ref.watch(authRepoProvider)),
);

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>(
  (ref) => GetCurrentUserUseCase(ref.watch(authRepoProvider)),
);

final deleteAccountUseCaseProvider = Provider<DeleteAccountUseCase>(
  (ref) => DeleteAccountUseCase(ref.watch(authRepoProvider)),
);

// Proveïdors dels casos d'ús d'entrades -------------------

final getUserEntriesUseCaseProvider = Provider<GetUserEntriesUseCase>(
  (ref) => GetUserEntriesUseCase(ref.watch(entriesRepoProvider)),
);

final createEntryUseCaseProvider = Provider<CreateEntryUseCase>(
  (ref) => CreateEntryUseCase(ref.watch(entriesRepoProvider)),
);

final updateEntryUseCaseProvider = Provider<UpdateEntryUseCase>(
  (ref) => UpdateEntryUseCase(ref.watch(entriesRepoProvider)),
);

final deleteEntryUseCaseProvider = Provider<DeleteEntryUseCase>(
  (ref) => DeleteEntryUseCase(ref.watch(entriesRepoProvider)),
);

final unlockVaultUseCaseProvider = Provider<UnlockVaultUseCase>(
  (ref) => UnlockVaultUseCase(ref.watch(entriesRepoProvider)),
);
