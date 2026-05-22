class FeedbackModel {
  const FeedbackModel({
    required this.message,
    this.appointmentNumber,
    this.rating,
  });

  final String message;
  final String? appointmentNumber;
  final int? rating;

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      if (appointmentNumber != null) 'appointment_number': appointmentNumber,
      if (rating != null) 'rating': rating,
    };
  }
}
