import 'package:flutter/widgets.dart';

import '../core/app_localizations.dart';

class ServiceModel {
  const ServiceModel({
    required this.id,
    required this.name,
    required this.requiredDocuments,
    required this.dailyLimit,
    this.description,
    this.translationKey,
    this.documentTranslationKeys = const [],
  });

  final int id;
  final String name;
  final String? description;
  final List<String> requiredDocuments;
  final int dailyLimit;
  final String? translationKey;
  final List<String> documentTranslationKeys;

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      requiredDocuments: ((json['required_documents'] ??
              json['requiredDocuments'] ??
              <dynamic>[]) as List<dynamic>)
          .map((document) => document.toString())
          .toList(),
      dailyLimit: (json['daily_limit'] ?? json['dailyLimit'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'required_documents': requiredDocuments,
      'daily_limit': dailyLimit,
    };
  }

  String localizedName(BuildContext context) {
    return translationKey == null ? name : context.tr(translationKey!);
  }

  List<String> localizedDocuments(BuildContext context) {
    if (documentTranslationKeys.isEmpty) return requiredDocuments;
    return documentTranslationKeys.map(context.tr).toList();
  }

  static List<ServiceModel> starterServices() {
    return const [
      ServiceModel(
        id: 1,
        name: 'ID issuance',
        translationKey: 'service_id_issuance',
        requiredDocuments: [],
        documentTranslationKeys: ['doc_current_photo', 'doc_house_number'],
        dailyLimit: 40,
      ),
      ServiceModel(
        id: 2,
        name: 'ID renewal',
        translationKey: 'service_id_renewal',
        requiredDocuments: [],
        documentTranslationKeys: ['doc_old_id', 'doc_current_photo'],
        dailyLimit: 35,
      ),
      ServiceModel(
        id: 3,
        name: 'Birth certificate',
        translationKey: 'service_birth_certificate',
        requiredDocuments: [],
        documentTranslationKeys: ['doc_birth_notice', 'doc_parent_id'],
        dailyLimit: 25,
      ),
      ServiceModel(
        id: 4,
        name: 'Marriage certificate',
        translationKey: 'service_marriage_certificate',
        requiredDocuments: [],
        documentTranslationKeys: ['doc_couple_id', 'doc_witness_id'],
        dailyLimit: 20,
      ),
      ServiceModel(
        id: 5,
        name: 'Death certificate',
        translationKey: 'service_death_certificate',
        requiredDocuments: [],
        documentTranslationKeys: ['doc_medical_certificate', 'doc_family_id'],
        dailyLimit: 20,
      ),
    ];
  }
}
