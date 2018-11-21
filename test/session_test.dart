import 'package:instiapp/src/json_parsing.dart';
import 'package:test/test.dart';

main() {
  test('Test json parsing of login session', () {
    var sess = parseSession(jsonStr);
    expect(sess.sessionid, "8ggfyzsgbvqbvivef5jh4tvmqa4fj4io");
    expect(sess.profile.profilePicUrl, "https://img.insti.app/profile/6745b48d7cec45dda25b953fa9833a71.jpg");
  });
}

final jsonStr = r"""
{
    "sessionid": "8ggfyzsgbvqbvivef5jh4tvmqa4fj4io",
    "user": "7580",
    "profile_id": "f923e3fe-1000-4767-b0c3-8988dce9d804",
    "profile": {
        "id": "f923e3fe-1000-4767-b0c3-8988dce9d804",
        "name": "Jon Snow",
        "profile_pic": "https://img.insti.app/profile/6745b48d7cec45dda25b953fa9833a71.jpg",
        "events_interested": [],
        "events_going": [
            {
                "id": "867f5dc3-794d-4a79-a7e1-a07a000f948e",
                "str_id": "fuss-talk-why-systems-fail-and-how-to-stop-them-867f5dc3",
                "name": "FUSS Talk: Why systems fail? And how to stop them?",
                "description": "## Why systems fail? - blue screen, leaked pictures, dictators, cancer - How to stop them?\n### Speaker: [Prof. Ashutosh Gupta](https://www.cse.iitb.ac.in/~akg/ \"Prof. Ashutosh Gupta's Homepage\")\n### Abstract\nAll aspects of our lives are becoming ever more complex. This is primarily due to our ever-increasing expectations to live a life that is  more comfortable, efficient, inclusive, etc. To achieve the expectations, we develop a variety of complex systems, e.g. governments,  corporations, hardware, software, etc. The expectations look deceptively simple. However, they are often in odds with each other and the sets of  behaviors we expect from the systems are mathematically ugly and not analyzable\nusing classical methods that have worked in basic sciences. We know from our personal experience that the systems are full of undesired behaviour.\n\nThe software is instances of such complex systems. An area of study has emerged, called ***formal verification***, to develop *theory and methods for ensuring the reliability of software*.\n\nIn this talk, we will discuss the principles involved in the area of formal verification. We will also see an introduction to the methods being developed to verify real-world systems, e.g., aeroplanes, medical devices, facebook, windows, etc. Subsequently, we will see Prof. Ashutosh Gupta's current work in *verification of concurrent programs* under ***weak memory models***. One will find that the ideas used in formal verification are also relevant in the analysis of any other complex system.",
                "image_url": "https://api.insti.app/static/upload/d2/5b/d25b85a3-b52c-47ff-8e58-b5e2f7f0daed-15880fcb-5bc.jpg.jpg",
                "start_time": "2018-10-24T17:15:00+05:30",
                "end_time": "2018-10-24T18:15:00+05:30",
                "all_day": false,
                "venues": [
                    {
                        "id": "0c320f01-cb8d-45a5-a4f4-bafdf881109e",
                        "name": "Faqir Chand Kohli Auditorium",
                        "short_name": "F.C Kohli",
                        "lat": null,
                        "lng": null
                    }
                ],
                "bodies": [
                    {
                        "id": "dcd2df7a-67dd-430b-ab79-135471fadf49",
                        "str_id": "cse",
                        "name": "Computer Science and Engineering",
                        "short_description": "CSE",
                        "website_url": "https://www.cse.iitb.ac.in",
                        "image_url": "https://api.insti.app/static/upload/d2/5b/d25b85a3-b52c-47ff-8e58-b5e2f7f0daed-e1c95319-efe.jpg.jpg",
                        "cover_url": null
                    },
                    {
                        "id": "252ddc80-910b-4f63-b68a-de30a62a947e",
                        "str_id": "department-talks",
                        "name": "Department Talks",
                        "short_description": "Talks organized by individual departments",
                        "website_url": null,
                        "image_url": "https://api.insti.app/static/upload/54aa5e79-84b.png",
                        "cover_url": null
                    },
                    {
                        "id": "44fe710a-8ede-4d59-a25b-a86434373209",
                        "str_id": "ugac",
                        "name": "UGAC",
                        "short_description": "Undergraduate Academic Council",
                        "website_url": "https://gymkhana.iitb.ac.in/~ugacademics/app/#/ugacads",
                        "image_url": "https://api.insti.app/static/upload/2c/d8/2cd8bf5c-eafb-409b-8a04-f62f94ccd58d-c8909196-942.png.jpg",
                        "cover_url": null
                    }
                ],
                "interested_count": 0,
                "going_count": 1,
                "website_url": "https://www.cse.iitb.ac.in/~fuss/",
                "weight": 400.0,
                "user_ues": null
            }
        ],
        "email": "tastelessjolt@iitb.ac.in",
        "roll_no": "1X00X00XX",
        "contact_no": "880XXXXXXX",
        "about": null,
        "followed_bodies": [
            {
                "id": "04794333-5c7e-4d82-87b1-9ec5347155d9",
                "str_id": "placement-cell",
                "name": "Placement Cell",
                "short_description": "Placements and Training",
                "website_url": "http://placements.iitb.ac.in/",
                "image_url": "https://api.insti.app/static/upload/b23be3e9-d9a.png",
                "cover_url": null
            }
        ],
        "roles": [],
        "institute_roles": [],
        "website_url": null,
        "ldap_id": "tastelessjolt",
        "hostel": "4",
        "former_roles": []
    }
}
""";