class ResearchProject {
  final int id;
  final String projectUid;
  final String title;
  final String description;
  final String professorName;
  final String domain;
  final double cpi;
  final String duration;
  final String campusStayRequired;
  final String weeklyTimeCommitment;
  final String? image;
  final List<String> allowedDepartments;
  final List<String> allowedDegrees;

  ResearchProject({
    required this.id,
    required this.projectUid,
    required this.title,
    required this.description,
    required this.professorName,
    required this.domain,
    required this.cpi,
    required this.duration,
    required this.campusStayRequired,
    required this.weeklyTimeCommitment,
    this.image,
    required this.allowedDepartments,
    required this.allowedDegrees,
  });

  factory ResearchProject.fromJson(Map<String, dynamic> json) {
    return ResearchProject(
      id: json['id'],
      projectUid: json['project_uid'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      professorName: json['professor_name'] ?? '',
      domain: json['domain'] ?? '',
      cpi: (json['cpi'] ?? 0).toDouble(),
      duration: json['duration'] ?? '',
      campusStayRequired: json['campus_stay_required'] ?? '',
      weeklyTimeCommitment: json['weekly_time_commitment'] ?? '',
      image: json['image'],
      allowedDepartments: List<String>.from(json['allowed_departments'] ?? []),
      allowedDegrees: List<String>.from(json['allowed_degrees'] ?? []),
    );
  }
}