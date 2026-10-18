import 'package:flutter_test/flutter_test.dart';
import 'package:InstiApp/src/api/model/blog_api.dart';

void main() {
  group('blog API responses', () {
    test('parses filters and company slugs', () {
      final filters = BlogFiltersResponse.fromJson({
        'domains': ['AI', 'Systems'],
        'categories': ['I1'],
        'companies': [
          {
            'company_name': 'Example Corp',
            'company_slug': 'example-corp',
          },
        ],
      });

      expect(filters.domains, ['AI', 'Systems']);
      expect(filters.categories, ['I1']);
      expect(filters.companies.single.companyName, 'Example Corp');
      expect(filters.companies.single.companySlug, 'example-corp');
    });

    test('parses paginated posts and extracted data', () {
      final page = BlogPostsPage.fromJson({
        'count': 21,
        'next': 'https://example.test/posts/?page=2',
        'previous': null,
        'results': [
          {
            'id': 'post-uuid',
            'company_slug': 'example-corp',
            'post_type': 'IAF_OPEN',
            'post_type_display': 'IAF Open',
            'raw_company_name': 'Example Corp',
            'published': '2026-01-10T09:00:00+05:30',
            'link': 'https://example.test/post',
            'pinned': true,
            'extracted_data': {
              'role': 'Software Engineer',
              'domain': 'AI',
              'category': 'I1',
            },
            'raw_content': 'Post body',
          },
        ],
      });

      expect(page.count, 21);
      expect(page.next, 'https://example.test/posts/?page=2');
      expect(page.results.single.id, 'post-uuid');
      expect(page.results.single.title, 'Example Corp | Software Engineer');
      expect(page.results.single.pinned, isTrue);
      expect(page.results.single.extractedData['category'], 'I1');
      expect(page.results.single.content, 'Post body');
    });

    test('parses company threads and nested posts', () {
      final page = BlogThreadsPage.fromJson({
        'count': 1,
        'next': null,
        'previous': null,
        'results': [
          {
            'id': 12,
            'company_name': 'Example Corp',
            'company_slug': 'example-corp',
            'first_post_date': '2026-01-10T09:00:00+05:30',
            'category': 'I1',
            'role': 'Software Engineer',
            'domain': 'AI',
            'stipend': '...',
            'iaf_deadline': '2026-01-15T23:59:00+05:30',
            'posts': [
              {
                'id': 'post-uuid',
                'company_slug': 'example-corp',
                'post_type': 'IAF_OPEN',
                'post_type_display': 'IAF Open',
                'raw_company_name': 'Example Corp',
                'published': '2026-01-10T09:00:00+05:30',
                'link': 'https://example.test/post',
                'pinned': false,
                'extracted_data': {},
                'raw_content': 'Post body',
              },
            ],
          },
        ],
      });

      final thread = page.results.single;
      expect(thread.companyName, 'Example Corp');
      expect(thread.category, 'I1');
      expect(thread.details['stipend'], '...');
      expect(thread.posts.single.postTypeDisplay, 'IAF Open');
      expect(thread.posts.single.content, 'Post body');
      expect(page.next, isNull);
    });
  });
}
