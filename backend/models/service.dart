class Service {
  const Service({
    required this.id,
    required this.name,
    required this.requiredDocuments,
    required this.dailyLimit,
    this.description,
  });

  final int id;
  final String name;
  final String? description;
  final List<String> requiredDocuments;
  final int dailyLimit;

  factory Service.fromRow(Map<String, dynamic> row) {
    final documents = row['required_documents'];
    return Service(
      id: row['id'] as int,
      name: row['name'] as String,
      description: row['description'] as String?,
      requiredDocuments: documents is List<String>
          ? documents
          : documents.toString().split('|').where((item) => item.isNotEmpty).toList(),
      dailyLimit: row['daily_limit'] as int,
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
}
