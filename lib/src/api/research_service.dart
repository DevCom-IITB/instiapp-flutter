import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:InstiApp/src/api/model/research_project.dart';

class ResearchService {
  static Future<List<ResearchProject>> fetchProjects() async {
    final response = await http.get(
      Uri.parse(
          "https://reach.gymkhana.iitb.ac.in/api/professor/instiapp/get_projects"),
      headers: {'X-Secret-Key': "abcd"},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => ResearchProject.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load research projects');
    }
  }
}
