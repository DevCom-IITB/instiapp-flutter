// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Session _$SessionFromJson(Map<String, dynamic> json) => Session(
      sessionid: json['sessionid'] as String?,
      user: json['user'] as String?,
      profileId: json['profile_id'] as String?,
      profile: json['profile'] == null
          ? null
          : User.fromJson(json['profile'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SessionToJson(Session instance) => <String, dynamic>{
      'sessionid': instance.sessionid,
      'user': instance.user,
      'profile_id': instance.profileId,
      'profile': instance.profile,
    };

Interest _$InterestFromJson(Map<String, dynamic> json) => Interest(
      id: json['id'] as String?,
      title: json['title'] as String?,
    );

Map<String, dynamic> _$InterestToJson(Interest instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
    };

Skill _$SkillFromJson(Map<String, dynamic> json) => Skill(
      title: json['title'] as String?,
      body: json['body'] == null
          ? null
          : Body.fromJson(json['body'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SkillToJson(Skill instance) => <String, dynamic>{
      'title': instance.title,
      'body': instance.body,
    };

User _$UserFromJson(Map<String, dynamic> json) => User(
      userID: json['id'] as String?,
      userName: json['name'] as String?,
      userProfilePictureUrl: json['profile_pic'] as String?,
      userInterestedEvents: (json['events_interested'] as List<dynamic>?)
          ?.map((e) => Event.fromJson(e as Map<String, dynamic>))
          .toList(),
      userGoingEvents: (json['events_going'] as List<dynamic>?)
          ?.map((e) => Event.fromJson(e as Map<String, dynamic>))
          .toList(),
      userEmail: json['email'] as String?,
      userRollNumber: json['roll_no'] as String?,
      userContactNumber: json['contact_no'] as String?,
      currentRole: json['currentRole'] as String?,
      hostel: json['hostel'] as String?,
      userAbout: json['about'] as String?,
      userFollowedBodies: (json['followed_bodies'] as List<dynamic>?)
          ?.map((e) => Body.fromJson(e as Map<String, dynamic>))
          .toList(),
      userFollowedBodiesID: (json['followed_bodies_id'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      userFormerRoles: (json['former_roles'] as List<dynamic>?)
          ?.map((e) => Role.fromJson(e as Map<String, dynamic>))
          .toList(),
      userInstituteRoles: (json['institute_roles'] as List<dynamic>?)
          ?.map((e) => Role.fromJson(e as Map<String, dynamic>))
          .toList(),
      userLDAPId: json['ldap_id'] as String?,
      userRoles: (json['roles'] as List<dynamic>?)
          ?.map((e) => Role.fromJson(e as Map<String, dynamic>))
          .toList(),
      userShowContactNumber: json['show_contact_no'] as bool?,
      userWebsiteURL: json['website_url'] as String?,
      interests: (json['interests'] as List<dynamic>?)
          ?.map((e) => Interest.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.userID,
      'name': instance.userName,
      'profile_pic': instance.userProfilePictureUrl,
      'events_interested': instance.userInterestedEvents,
      'events_going': instance.userGoingEvents,
      'email': instance.userEmail,
      'roll_no': instance.userRollNumber,
      'contact_no': instance.userContactNumber,
      'show_contact_no': instance.userShowContactNumber,
      'about': instance.userAbout,
      'followed_bodies': instance.userFollowedBodies,
      'followed_bodies_id': instance.userFollowedBodiesID,
      'roles': instance.userRoles,
      'institute_roles': instance.userInstituteRoles,
      'former_roles': instance.userFormerRoles,
      'website_url': instance.userWebsiteURL,
      'ldap_id': instance.userLDAPId,
      'hostel': instance.hostel,
      'interests': instance.interests,
      'currentRole': instance.currentRole,
    };
