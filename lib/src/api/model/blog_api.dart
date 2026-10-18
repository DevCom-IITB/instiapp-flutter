import 'package:InstiApp/src/api/model/post.dart';

class BlogCompanyOption {
  final String companyName;
  final String companySlug;

  const BlogCompanyOption({
    required this.companyName,
    required this.companySlug,
  });

  factory BlogCompanyOption.fromJson(Map<String, dynamic> json) =>
      BlogCompanyOption(
        companyName: json['company_name'] as String? ?? '',
        companySlug: json['company_slug'] as String? ?? '',
      );
}

class BlogFiltersResponse {
  final List<String> domains;
  final List<String> categories;
  final List<BlogCompanyOption> companies;

  const BlogFiltersResponse({
    this.domains = const [],
    this.categories = const [],
    this.companies = const [],
  });

  factory BlogFiltersResponse.fromJson(Map<String, dynamic> json) =>
      BlogFiltersResponse(
        domains: (json['domains'] as List<dynamic>? ?? []).cast<String>(),
        categories: (json['categories'] as List<dynamic>? ?? []).cast<String>(),
        companies: (json['companies'] as List<dynamic>? ?? [])
            .map((item) =>
                BlogCompanyOption.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
}

class ApiBlogPost extends Post {
  final String companySlug;
  final String postType;
  final String postTypeDisplay;
  final String rawCompanyName;
  final bool pinned;
  final Map<String, dynamic> extractedData;

  ApiBlogPost({
    required String id,
    required this.companySlug,
    required this.postType,
    required this.postTypeDisplay,
    required this.rawCompanyName,
    required String published,
    required String link,
    required this.pinned,
    required this.extractedData,
    required String rawContent,
    String? title,
  }) : super(
          id: id,
          title: title ?? rawCompanyName,
          content: rawContent,
          published: published,
          link: link,
        );

  factory ApiBlogPost.fromJson(Map<String, dynamic> json) {
    final extractedData = Map<String, dynamic>.from(
      (json['extracted_data'] as Map?) ?? const {},
    );
    final companyName = json['raw_company_name'] as String? ?? '';
    final role = extractedData['role'] as String? ?? '';
    return ApiBlogPost(
      id: json['id']?.toString() ?? '',
      companySlug: json['company_slug'] as String? ?? '',
      postType: json['post_type'] as String? ?? '',
      postTypeDisplay: json['post_type_display'] as String? ?? '',
      rawCompanyName: companyName,
      published: json['published'] as String? ?? '',
      link: json['link'] as String? ?? '',
      pinned: json['pinned'] as bool? ?? false,
      extractedData: extractedData,
      rawContent: json['raw_content'] as String? ?? '',
      title: role.isEmpty ? companyName : '$companyName | $role',
    );
  }
}

class BlogThread {
  final int id;
  final String companyName;
  final String companySlug;
  final String firstPostDate;
  final String category;
  final String role;
  final String domain;
  final Map<String, dynamic> details;
  final List<ApiBlogPost> posts;

  const BlogThread({
    required this.id,
    required this.companyName,
    required this.companySlug,
    required this.firstPostDate,
    required this.category,
    required this.role,
    required this.domain,
    required this.details,
    required this.posts,
  });

  factory BlogThread.fromJson(Map<String, dynamic> json) => BlogThread(
        id: (json['id'] as num?)?.toInt() ?? 0,
        companyName: json['company_name'] as String? ?? '',
        companySlug: json['company_slug'] as String? ?? '',
        firstPostDate: json['first_post_date'] as String? ?? '',
        category: json['category'] as String? ?? '',
        role: json['role'] as String? ?? '',
        domain: json['domain'] as String? ?? '',
        details: Map<String, dynamic>.from(json)
          ..removeWhere((key, _) => const {
                'id',
                'company_name',
                'company_slug',
                'first_post_date',
                'category',
                'role',
                'domain',
                'posts',
              }.contains(key)),
        posts: (json['posts'] as List<dynamic>? ?? [])
            .map((item) => ApiBlogPost.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
}

class BlogPostsPage {
  final int count;
  final String? next;
  final List<ApiBlogPost> results;

  const BlogPostsPage({
    this.count = 0,
    this.next,
    this.results = const [],
  });

  factory BlogPostsPage.fromJson(Map<String, dynamic> json) => BlogPostsPage(
        count: (json['count'] as num?)?.toInt() ?? 0,
        next: json['next'] as String?,
        results: (json['results'] as List<dynamic>? ?? [])
            .map((item) => ApiBlogPost.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
}

class BlogThreadsPage {
  final int count;
  final String? next;
  final List<BlogThread> results;

  const BlogThreadsPage({
    this.count = 0,
    this.next,
    this.results = const [],
  });

  factory BlogThreadsPage.fromJson(Map<String, dynamic> json) =>
      BlogThreadsPage(
        count: (json['count'] as num?)?.toInt() ?? 0,
        next: json['next'] as String?,
        results: (json['results'] as List<dynamic>? ?? [])
            .map((item) => BlogThread.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
}
