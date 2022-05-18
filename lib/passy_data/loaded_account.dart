import 'dart:async';
import 'dart:ui';

import 'package:encrypt/encrypt.dart';
import 'package:universal_io/io.dart';

import 'account_credentials.dart';
import 'account_settings.dart';
import 'common.dart';
import 'entry_event.dart';
import 'entry_type.dart';
import 'history.dart';
import 'host_address.dart';
import 'id_card.dart';
import 'identity.dart';
import 'images.dart';
import 'note.dart';
import 'password.dart';
import 'passy_bytes.dart';
import 'passy_entry.dart';
import 'payment_card.dart';
import 'screen.dart';
import 'synchronization.dart';

class LoadedAccount {
  final AccountCredentialsFile _credentials;
  final AccountSettingsFile _settings;
  final HistoryFile _history;
  final PasswordsFile _passwords;
  final PassyImages _passwordIcons;
  final NotesFile _notes;
  final PaymentCardsFile _paymentCards;
  final IDCardsFile _idCards;
  final IdentitiesFile _identities;
  Encrypter _encrypter;

  LoadedAccount(
    AccountCredentialsFile credentials, {
    required String path,
    required Encrypter encrypter,
  })  : _encrypter = encrypter,
        _credentials = credentials,
        _settings = AccountSettings.fromFile(
            File(path + Platform.pathSeparator + 'settings.enc'),
            encrypter: encrypter),
        _history = History.fromFile(
            File(path + Platform.pathSeparator + 'history.enc'),
            encrypter: encrypter),
        _passwords = Passwords.fromFile(
            File(path + Platform.pathSeparator + 'passwords.enc'),
            encrypter: encrypter),
        _passwordIcons = PassyImages(
            path + Platform.pathSeparator + 'password_icons',
            encrypter: encrypter),
        _notes = Notes.fromFile(
            File(path + Platform.pathSeparator + 'notes.enc'),
            encrypter: encrypter),
        _paymentCards = PaymentCards.fromFile(
            File(path + Platform.pathSeparator + 'payment_cards.enc'),
            encrypter: encrypter),
        _idCards = IDCards.fromFile(
            File(path + Platform.pathSeparator + 'id_cards.enc'),
            encrypter: encrypter),
        _identities = Identities.fromFile(
            File(path + Platform.pathSeparator + 'identities.enc'),
            encrypter: encrypter);

  void _setAccountPassword(String password) {
    _credentials.value.password = password;
    _encrypter = getEncrypter(password);
    _settings.encrypter = _encrypter;
    _history.encrypter = _encrypter;
    _passwords.encrypter = _encrypter;
    _passwordIcons.encrypter = _encrypter;
    _notes.encrypter = _encrypter;
    _paymentCards.encrypter = _encrypter;
    _idCards.encrypter = _encrypter;
    _identities.encrypter = _encrypter;
  }

  Future<void> setAccountPassword(String password) {
    _setAccountPassword(password);
    return save();
  }

  void setAccountPasswordSync(String password) {
    _setAccountPassword(password);
    saveSync();
  }

  Future<void> save() async {
    await _settings.save();
    await _history.save();
    await _passwords.save();
    await _passwordIcons.save();
    await _notes.save();
    await _paymentCards.save();
    await _idCards.save();
    await _identities.save();
  }

  void saveSync() {
    _settings.saveSync();
    _history.saveSync();
    _passwords.saveSync();
    _passwordIcons.saveSync();
    _notes.saveSync();
    _paymentCards.saveSync();
    _idCards.saveSync();
    _identities.saveSync();
  }

  Future<HostAddress?> host({
    void Function()? onConnected,
    void Function()? onComplete,
    void Function(String log)? onError,
  }) =>
      Synchronization(this,
              history: _history.value,
              encrypter: _encrypter,
              onComplete: onComplete,
              onError: onError)
          .host(onConnected: onConnected);

  Future<void> connect(
    HostAddress address, {
    void Function()? onConnected,
    void Function()? onComplete,
    void Function(String log)? onError,
  }) {
    onConnected?.call();
    Future<void> _connectFuture = Synchronization(this,
        history: _history.value,
        encrypter: _encrypter,
        onComplete: () => onComplete?.call(),
        onError: (log) => onError?.call(log)).connect(address);
    return _connectFuture;
  }

  void Function(PassyEntry value) setEntry(EntryType type) {
    switch (type) {
      case EntryType.password:
        return (PassyEntry value) => setPassword(value as Password);
      case EntryType.passwordIcon:
        return (PassyEntry value) => setPasswordIcon(value as PassyBytes);
      case EntryType.paymentCard:
        return (PassyEntry value) => setPaymentCard(value as PaymentCard);
      case EntryType.note:
        return (PassyEntry value) => setNote(value as Note);
      case EntryType.idCard:
        return (PassyEntry value) => setIDCard(value as IDCard);
      case EntryType.identity:
        return (PassyEntry value) => setIdentity(value as Identity);
      default:
        throw Exception('Unsupported entry type \'${type.name}\'');
    }
  }

  PassyEntry? Function(String key) getEntry(EntryType type) {
    switch (type) {
      case EntryType.password:
        return getPassword;
      case EntryType.passwordIcon:
        return getPasswordIcon;
      case EntryType.paymentCard:
        return getPaymentCard;
      case EntryType.note:
        return getNote;
      case EntryType.idCard:
        return getIDCard;
      case EntryType.identity:
        return getIdentity;
      default:
        throw Exception('Unsupported entry type \'${type.name}\'');
    }
  }

  void Function(String key) removeEntry(EntryType type) {
    switch (type) {
      case EntryType.password:
        return removePassword;
      case EntryType.passwordIcon:
        return removePasswordIcon;
      case EntryType.paymentCard:
        return removePaymentCard;
      case EntryType.note:
        return removeNote;
      case EntryType.idCard:
        return removeIDCard;
      case EntryType.identity:
        return removeIdentity;
      default:
        throw Exception('Unsupported entry type \'${type.name}\'');
    }
  }

  // Account Credentials wrappers
  String get username => _credentials.value.username;
  set username(String value) => _credentials.value.username = value;
  String get passwordHash => _credentials.value.passwordHash;

  // Account Info wrappers
  String get icon => _settings.value.icon;
  set icon(String value) => _settings.value.icon = value;
  Color get color => _settings.value.color;
  set color(Color value) => _settings.value.color = color;
  Screen get defaultScreen => _settings.value.defaultScreen;
  set defaultScreen(Screen value) => _settings.value.defaultScreen = value;

  // Passwords wrappers
  Iterable<Password> get passwords => _passwords.value.entries;

  Password? getPassword(String key) => _passwords.value.getEntry(key);

  void setPassword(Password password) {
    _history.value.passwords[password.key] = EntryEvent(password.key,
        status: EntryStatus.alive, lastModified: DateTime.now().toUtc());
    _passwords.value.setEntry(password);
  }

  void removePassword(String key) {
    _history.value.passwords[key]!
      ..status = EntryStatus.removed
      ..lastModified = DateTime.now().toUtc();
    _passwords.value.removeEntry(key);
  }

  // Password Icons wrappers
  PassyBytes? getPasswordIcon(String name) => _passwordIcons.getEntry(name);

  void setPasswordIcon(PassyBytes passwordIcon) {
    _history.value.passwordIcons[passwordIcon.key] = EntryEvent(
        passwordIcon.key,
        status: EntryStatus.alive,
        lastModified: DateTime.now().toUtc());
    _passwordIcons.setEntry(passwordIcon);
  }

  void removePasswordIcon(String key) {
    _history.value.passwordIcons[key]!
      ..status = EntryStatus.removed
      ..lastModified = DateTime.now().toUtc();
    _passwordIcons.removeEntry(key);
  }

  // Notes wrappers
  Iterable<Note> get notes => _notes.value.entries;

  Note? getNote(String key) => _notes.value.getEntry(key);

  void setNote(Note note) {
    _history.value.notes[note.key] = EntryEvent(
      note.key,
      status: EntryStatus.alive,
      lastModified: DateTime.now().toUtc(),
    );
    _notes.value.setEntry(note);
  }

  void removeNote(String key) {
    _history.value.notes[key]!
      ..status = EntryStatus.removed
      ..lastModified = DateTime.now().toUtc();
    _notes.value.removeEntry(key);
  }

  // Payment Cards wrappers
  Iterable<PaymentCard> get paymentCards => _paymentCards.value.entries;

  PaymentCard? getPaymentCard(String key) => _paymentCards.value.getEntry(key);

  void setPaymentCard(PaymentCard paymentCard) {
    _history.value.paymentCards[paymentCard.key] = EntryEvent(
      paymentCard.key,
      status: EntryStatus.alive,
      lastModified: DateTime.now().toUtc(),
    );
    _paymentCards.value.setEntry(paymentCard);
  }

  void removePaymentCard(String key) {
    _history.value.paymentCards[key]!
      ..status = EntryStatus.removed
      ..lastModified = DateTime.now().toUtc();
    _paymentCards.value.removeEntry(key);
  }

  // ID Cards wrappers
  Iterable<IDCard> get idCards => _idCards.value.entries;

  IDCard? getIDCard(String key) => _idCards.value.getEntry(key);

  void setIDCard(IDCard idCard) {
    _history.value.idCards[idCard.key] = EntryEvent(
      idCard.key,
      status: EntryStatus.alive,
      lastModified: DateTime.now().toUtc(),
    );
    _idCards.value.setEntry(idCard);
  }

  void removeIDCard(String key) {
    _history.value.idCards[key]!
      ..status = EntryStatus.removed
      ..lastModified = DateTime.now().toUtc();
    _idCards.value.removeEntry(key);
  }

  // Identities wrappers
  Iterable<Identity> get identities => _identities.value.entries;

  Identity? getIdentity(String key) => _identities.value.getEntry(key);

  void setIdentity(Identity identity) {
    _history.value.identities[identity.key] = EntryEvent(
      identity.key,
      status: EntryStatus.alive,
      lastModified: DateTime.now().toUtc(),
    );
    _identities.value.setEntry(identity);
  }

  void removeIdentity(String key) {
    _history.value.identities[key]!
      ..status = EntryStatus.removed
      ..lastModified = DateTime.now().toUtc();
    _identities.value.removeEntry(key);
  }
}
