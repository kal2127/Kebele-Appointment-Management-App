class ResidentFeedback {
  const ResidentFeedback({
    required this.message,
    this.appointmentNumber,
    this.rating,
  });

  final String message;
  final String? appointmentNumber;
  final int? rating;
}
