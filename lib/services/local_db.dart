import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/future_plan.dart';
import '../models/invoice.dart';

class LocalDb {
  static const String invoicesBoxName = 'invoices';
  static const String plansBoxName = 'plans';
  static const String settingsBoxName = 'settings';

  static const String pinKey = 'pin_hash';

  static late Box invoicesBox;
  static late Box plansBox;
  static late Box settingsBox;

  static Future<void> init() async {
    await Hive.initFlutter();

    invoicesBox = await Hive.openBox(invoicesBoxName);
    plansBox = await Hive.openBox(plansBoxName);
    settingsBox = await Hive.openBox(settingsBoxName);
  }

  static String _hashPin(String pin) {
    return sha256.convert(utf8.encode(pin)).toString();
  }

  static bool get hasPin {
    return settingsBox.get(pinKey) != null;
  }

  static Future<void> savePin(String pin) async {
    await settingsBox.put(pinKey, _hashPin(pin));
  }

  static bool verifyPin(String pin) {
    final savedHash = settingsBox.get(pinKey);
    if (savedHash == null) return false;
    return savedHash == _hashPin(pin);
  }

  static List<Invoice> getInvoices() {
    final invoices = invoicesBox.values
        .map((e) => Invoice.fromMap(Map.from(e)))
        .toList();

    invoices.sort((a, b) => b.date.compareTo(a.date));
    return invoices;
  }

  static Future<void> saveInvoice(Invoice invoice) async {
    await invoicesBox.put(invoice.id, invoice.toMap());
  }

  static Future<void> deleteInvoice(String id) async {
    await invoicesBox.delete(id);
  }

  static List<FuturePlan> getPlans() {
    final plans = plansBox.values
        .map((e) => FuturePlan.fromMap(Map.from(e)))
        .toList();

    plans.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return plans;
  }

  static Future<void> savePlan(FuturePlan plan) async {
    await plansBox.put(plan.id, plan.toMap());
  }

  static Future<void> deletePlan(String id) async {
    await plansBox.delete(id);
  }

  static Future<bool> changePin({
    required String currentPin,
    required String newPin,
  }) async {
    if (!verifyPin(currentPin)) {
      return false;
    }

    await savePin(newPin);
    return true;
  }
}