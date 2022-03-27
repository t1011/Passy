import 'dart:typed_data';
import 'dart:ui';

import 'package:encrypt/encrypt.dart';
import 'package:passy/passy/common.dart';
import 'package:passy/passy/entry_event.dart';
import 'package:passy/passy/history.dart';
import 'package:passy/passy/id_card.dart';
import 'package:passy/passy/identity.dart';
import 'package:passy/passy/images.dart';
import 'package:passy/passy/password.dart';
import 'package:passy/passy/payment_card.dart';
import 'package:universal_io/io.dart';

import 'account_info.dart';
import 'dated_entries.dart';
import 'note.dart';

class LoadedAccount {
  final AccountInfo _accountInfo;
  final History _history;
  final DatedEntries<Password> _passwords;
  final Images _passwordIcons;
  final DatedEntries<Note> _notes;
  final DatedEntries<PaymentCard> _paymentCards;
  final DatedEntries<IDCard> _idCards;
  final DatedEntries<Identity> _identities;

  void _setAccountPassword(String password) {
    _accountInfo.password = password;
    Encrypter _encrypter = getEncrypter(password);
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
    await _accountInfo.save();
    await _history.save();
    await _passwords.save();
    await _passwordIcons.save();
    await _notes.save();
    await _paymentCards.save();
    await _idCards.save();
    await _identities.save();
  }

  void saveSync() {
    _accountInfo.saveSync();
    _history.saveSync();
    _passwords.saveSync();
    _passwordIcons.saveSync();
    _notes.saveSync();
    _paymentCards.saveSync();
    _idCards.saveSync();
    _identities.saveSync();
  }

  // Account Info wrappers
  String get username => _accountInfo.username;
  set username(String value) => _accountInfo.username = value;
  String get icon => _accountInfo.icon;
  set icon(String value) => _accountInfo.icon = value;
  Color get color => _accountInfo.color;
  set color(Color value) => _accountInfo.color = color;
  String get passwordHash => _accountInfo.passwordHash;

  // Passwords wrappers
  Iterable<Password> get passwords => _passwords.entries;
  void addPassword(Password password) {
    _history.passwords[password.creationDate] = EntryEvent(
        status: EntryStatus.alive, lastModified: DateTime.now().toUtc());
    _passwords.add(password);
  }

  void setPassword(Password password) =>
      _history.passwords[password.creationDate]!.lastModified = DateTime.now();

  void removePassword(Password password) {
    _history.passwords[password.creationDate] = EntryEvent(
        status: EntryStatus.removed, lastModified: DateTime.now().toUtc());
    _passwords.remove(password);
  }

  // Password Icons wrappers
  Uint8List? getPasswordIcon(String name) => _passwordIcons.getImage(name);

  void setPasswordIcon(String name, Uint8List image) {
    _history.passwordIcons[name] = EntryEvent(
        status: EntryStatus.alive, lastModified: DateTime.now().toUtc());
    _passwordIcons.setImage(name, image);
  }

  // Notes wrappers
  Iterable<Note> get notes => _notes.entries;
  void addNote(Note note) {
    _history.notes[note.creationDate] = EntryEvent(
        status: EntryStatus.alive, lastModified: DateTime.now().toUtc());
    _notes.add(note);
  }

  void setNote(Note note) =>
      _history.notes[note.creationDate]!.lastModified = DateTime.now();

  void removeNote(Note note) {
    _history.notes[note.creationDate] = EntryEvent(
        status: EntryStatus.removed, lastModified: DateTime.now().toUtc());
    _notes.remove(note);
  }

  // Payment Cards wrappers
  Iterable<PaymentCard> get paymentCards => _paymentCards.entries;
  void addPaymentCard(PaymentCard paymentCard) {
    _history.paymentCards[paymentCard.creationDate] = EntryEvent(
        status: EntryStatus.alive, lastModified: DateTime.now().toUtc());
    _paymentCards.add(paymentCard);
  }

  void setPaymentCard(PaymentCard paymentCard) =>
      _history.paymentCards[paymentCard.creationDate]!.lastModified =
          DateTime.now();

  void removePaymentCard(PaymentCard paymentCard) {
    _history.paymentCards[paymentCard.creationDate] = EntryEvent(
        status: EntryStatus.removed, lastModified: DateTime.now().toUtc());
    _paymentCards.remove(paymentCard);
  }

  // ID Cards wrappers
  Iterable<IDCard> get idCards => _idCards.entries;
  void addIDCard(IDCard idCard) {
    _history.idCards[idCard.creationDate] = EntryEvent(
        status: EntryStatus.alive, lastModified: DateTime.now().toUtc());
    _idCards.add(idCard);
  }

  void setIDCard(IDCard idCard) =>
      _history.idCards[idCard.creationDate]!.lastModified = DateTime.now();

  void removeIDCard(IDCard idCard) {
    _history.idCards[idCard.creationDate] = EntryEvent(
        status: EntryStatus.removed, lastModified: DateTime.now().toUtc());
    _idCards.remove(idCard);
  }

  // Identities wrappers
  Iterable<Identity> get identities => _identities.entries;
  void addIdentity(Identity identity) {
    _history.identities[identity.creationDate] = EntryEvent(
        status: EntryStatus.alive, lastModified: DateTime.now().toUtc());
    _identities.add(identity);
  }

  void setIdentity(Identity identity) =>
      _history.identities[identity.creationDate]!.lastModified = DateTime.now();

  void removeIdentity(Identity identity) {
    _history.identities[identity.creationDate] = EntryEvent(
        status: EntryStatus.removed, lastModified: DateTime.now().toUtc());
    _identities.remove(identity);
  }

  LoadedAccount(this._accountInfo, {required Encrypter encrypter})
      : _history = History(
            File(_accountInfo.path + Platform.pathSeparator + 'history.enc'),
            encrypter: encrypter),
        _passwords = DatedEntries<Password>(
            File(_accountInfo.path + Platform.pathSeparator + 'passwords.enc'),
            encrypter: encrypter),
        _passwordIcons = Images(
            _accountInfo.path + Platform.pathSeparator + 'password_icons',
            encrypter: encrypter),
        _notes = DatedEntries<Note>(
            File(_accountInfo.path + Platform.pathSeparator + 'notes.enc'),
            encrypter: encrypter),
        _paymentCards = DatedEntries<PaymentCard>(
            File(_accountInfo.path +
                Platform.pathSeparator +
                'payment_cards.enc'),
            encrypter: encrypter),
        _idCards = DatedEntries<IDCard>(
            File(_accountInfo.path + Platform.pathSeparator + 'id_cards.enc'),
            encrypter: encrypter),
        _identities = DatedEntries<Identity>(
            File(_accountInfo.path + Platform.pathSeparator + 'identities.enc'),
            encrypter: encrypter);
}
