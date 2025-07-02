import 'dart:async';
// import 'dart:math';
// import 'package:InstiApp/src/components/dropdowns.dart';
// import 'package:InstiApp/src/api/model/body.dart';
// import 'package:InstiApp/src/api/model/event.dart';
// import 'package:InstiApp/src/api/model/role.dart';
import 'package:InstiApp/src/api/model/user.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
// import 'package:InstiApp/src/drawer.dart';
// import 'package:InstiApp/src/routes/bodypage.dart';
// import 'package:InstiApp/src/routes/eventpage.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
// import 'package:InstiApp/src/utils/share_url_maker.dart';
// import 'package:InstiApp/src/utils/title_with_backbutton.dart';
import 'package:flutter/material.dart';
// import 'package:share/share.dart';
// import 'package:url_launcher/url_launcher.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:InstiApp/src/widgets/appbar.dart';
import 'package:InstiApp/src/widgets/buttons.dart';
import 'package:url_launcher/url_launcher.dart';

class UserPage extends StatefulWidget {
  final User? initialUser;
  final Future<User>? userFuture;

  UserPage({this.userFuture, this.initialUser});

  static void navigateWith(
      BuildContext context, InstiAppBloc bloc, User? user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: RouteSettings(
          name: "/user/${user?.userID ?? ""}",
        ),
        builder: (context) => UserPage(
          initialUser: user,
          userFuture: bloc.getUser(user?.userID ?? ""),
        ),
      ),
    );
  }

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage>
    with SingleTickerProviderStateMixin {
  User? user;
  bool cansee = false;
  TabController? _tabController;
  bool NotificationVisibility = true;
  List<Group> associations = [];
  List<Group> following = [];
  bool loggingOutLoading = false;
  bool updatingProfile = false;
  bool sendingFeedback = false;

  final String updateProfileUrl = "https://gymkhana.iitb.ac.in/sso/user";
  final String feedbackUrl = "https://insti.app/feedback";

  @override
  void initState() {
    super.initState();
    user = widget.initialUser;

    _loadUserData();
  }

  void _handleTabChange() {
    if (mounted) setState(() {});
  }

  Future<void> _loadUserData() async {
    try {
      // Load user data
      if (widget.userFuture != null) {
        final u = await widget.userFuture!;
        if (mounted) setState(() {
          user = u;
          associations = _convertRolesToGroups();
          following = _convertBodiesToGroups();
        });
      }

      // Check if current user
      final bloc = BlocProvider.of(context)!.bloc;
      if (bloc != null) {
        final currentUser = await bloc.getUser("me");
        if (mounted) {
          setState(() {
            cansee = currentUser.userLDAPId == widget.initialUser?.userLDAPId;
            
            _tabController = TabController(length: cansee ? 3 : 2, vsync: this);
            _tabController!.addListener(_handleTabChange);
          });
        }
      }
    } catch (e) {
      // Handle error
    }
  }

  List<Widget> _buildTabs(int tabCount) {
    if (tabCount == 3) {
      return [
        Tab(text: 'General', height: 64),
        Tab(text: 'Associations', height: 64),
        Tab(text: 'Following', height: 64),
      ];
    } else {
      return [
        Tab(text: 'Associations', height: 64),
        Tab(text: 'Following', height: 64),
      ];
    }
  }

  List<Widget> _buildTabViews(int tabCount) {
    if (tabCount == 3) {
      return [
        _buildSettingsSection(),
        _buildAssociationsSection(),
        _buildFollowingSection(),
      ];
    } else {
      return [
        _buildAssociationsSection(),
        _buildFollowingSection(),
      ];
    }
  }

  @override
  void dispose() {
    _tabController?.removeListener(_handleTabChange);
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    if (_tabController == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicatorExtended(label: Text("Loading tabs...")),
        ),
      );
    }

    final isGeneralTab = _tabController!.length == 3 && _tabController!.index == 0;
    final tabCount = _tabController!.length;

    return Scaffold(
      body: SafeArea(
        child: user == null
            ? Center(
                child: CircularProgressIndicatorExtended(
                    label: Text("Loading the User Page")))
            : Column(
                children: [
                  const SizedBox(height: 4),
                  const CustomAppBar(title: 'Profile'),
                  const SizedBox(height: 24),
                  cansee
                      ? AnimatedCrossFade(
                          duration: const Duration(milliseconds: 300),
                          crossFadeState: isGeneralTab
                              ? CrossFadeState.showFirst
                              : CrossFadeState.showSecond,
                          firstChild: _buildProfileCard(),
                          secondChild: _buildCompactProfileCard(),
                        )
                      : _spectatingProfileCard(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        TabBar(
                          controller: _tabController,
                          labelColor: Colors.blue,
                          labelStyle: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'DM Sans'),
                          labelPadding: EdgeInsets.all(0),
                          unselectedLabelColor: Colors.black,
                          unselectedLabelStyle: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'DM Sans'),
                          indicatorSize: TabBarIndicatorSize.tab,
                          indicatorWeight: 3,
                          indicatorColor: Colors.blue,
                          tabs: _buildTabs(tabCount)
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: _buildTabViews(tabCount)
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildProfileImage() {
    final profileUrl = user?.userProfilePictureUrl;

    // Case 1: No profile image available
    if (profileUrl == null || profileUrl.isEmpty) {
      return const Icon(
        Icons.person_outline_outlined,
        size: 50,
        color: Colors.grey,
      );
    }

    // Case 2: Valid image URL
    return Image.network(
      profileUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(child: CircularProgressIndicator());
      },
      errorBuilder: (context, error, stackTrace) => const Icon(
        Icons.person_outline_outlined,
        size: 50,
        color: Colors.grey,
      ),
    );
  }

  Widget _spectatingProfileCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/profilepage/othersprofiledoodle.png'),
            fit: BoxFit.cover,
          ),
          color: const Color(0xFF0F1620),
          borderRadius: BorderRadius.circular(16),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Image
              Container(
                width: 80,
                height: 80,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: _buildProfileImage(),
                ),
              ),

              const SizedBox(width: 16),

              // Name and Roll Number
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      user?.userName ?? 'Loading...',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textHeightBehavior: TextHeightBehavior(
                        applyHeightToFirstAscent: false,
                        applyHeightToLastDescent: false,
                      ),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      user?.userRollNumber ?? 'Loading...',
                      textHeightBehavior: TextHeightBehavior(
                        applyHeightToFirstAscent: false,
                        applyHeightToLastDescent: false,
                      ),
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 16),

              // Small Logo
              SizedBox(
                width: 50,
                height: 50,
                child: Center(
                  child: Image.asset(
                    'assets/profilepage/logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.school,
                      size: 45,
                      color: Colors.white54,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactProfileCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/profilepage/compact.png'),
            fit: BoxFit.cover,
          ),
          color: const Color(0xFF0F1620),
          borderRadius: BorderRadius.circular(16),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Image
              SizedBox(
                width: 88,
                child: Center(
                  child: Container(
                    width: 88,
                    height: 107, // match your original height
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _buildProfileImage(),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Name, ID, logo, and banner
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name + logo
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Name and ID
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.userName ?? 'Loading...',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textHeightBehavior: TextHeightBehavior(
                                  applyHeightToFirstAscent: false,
                                  applyHeightToLastDescent: false,
                                ),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                user?.userRollNumber ?? 'Loading...',
                                textHeightBehavior: TextHeightBehavior(
                                  applyHeightToFirstAscent: false,
                                  applyHeightToLastDescent: false,
                                ),
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Small Logo
                        SizedBox(
                          width: 35,
                          height: 35,
                          child: Center(
                            child: Image.asset(
                              'assets/profilepage/logo.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                Icons.school,
                                size: 35,
                                color: Colors.white54,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Banner Image
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: EdgeInsets.all(6),
                      margin: EdgeInsets.only(bottom: 4),
                      child: ClipRRect(
                        child: _buildRollNumberBarcode(height: 50),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0F1620),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 98,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _buildProfileImage(), // ✅ Reuse same logic
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProfileInfoItem(
                            'Name', user?.userName ?? 'Loading...', 16),
                        _buildProfileInfoItem(
                            'Programme', 'Loading...', 14),
                        _buildProfileInfoItem(
                          'Department',
                          'Loading...',
                          14,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        children: [
                          SizedBox(
                            width: 51,
                            height: 50,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.asset(
                                'assets/profilepage/logo.png',
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => const Icon(
                                  Icons.school,
                                  size: 35,
                                  color: Colors.white54,
                                ),
                              ),
                            ),
                          ),
                          const Text(
                            'IIT Bombay',
                            style: TextStyle(
                              color: Color(0xFF639DF6),
                              fontSize: 8,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      _buildProfileInfoItem('Validity', '31/07/2027', 14),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0F1620),
              image: DecorationImage(
                  image: AssetImage('assets/profilepage/Union.png'),
                  fit: BoxFit.cover),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    child: _buildRollNumberBarcode(height: 72),
                  ),
                  Text(
                    user?.userRollNumber ?? 'Loading...',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfoItem(String label, String value, double fsize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 10,
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: fsize,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
          softWrap: true,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildRollNumberBarcode({double? height}) {
    final rollNumber = user?.userRollNumber;
    
    if (rollNumber == null || rollNumber.isEmpty) {
      return Container(
        height: height ?? 50,
        color: Colors.white,
        child: Center(
          child: Text(
            'SCAN UNAVAILABLE',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    return BarcodeWidget(
      barcode: Barcode.code128(),
      data: rollNumber.toUpperCase(),
      width: double.infinity,
      height: height ?? 50,
      drawText: false,
    );
  }

  Widget _buildSettingsSection() {
    var bloc = BlocProvider.of(context)?.bloc;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        children: [
          ToggleItem(
            title: 'Notifications',
            value: NotificationVisibility,
            onChanged: (val) => setState(() => NotificationVisibility = val),
            top: true,
            icon: Icons.visibility_off_outlined,
          ),
          SettingsItem(
            title: 'Settings',
            icon: Icons.settings_outlined,
            onTap: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
          SettingsItem(
            title: updatingProfile ? 'Opening...' : 'Edit Profile',
            icon: Icons.edit_outlined,
            color: updatingProfile ? Colors.grey : null,
            onTap: () async {
              setState(() => updatingProfile = true);
              try {
                await Future.delayed(const Duration(milliseconds: 300));

                if (await canLaunchUrl(Uri.parse(updateProfileUrl))) {
                  await launchUrl(
                    Uri.parse(updateProfileUrl),
                    mode: LaunchMode.externalApplication,
                  );
                }
              } finally {
                setState(() => updatingProfile = false);
              }
            },
          ),
          SettingsItem(
            title: sendingFeedback ? 'Opening...' : 'Feedback',
            icon: Icons.feedback_outlined,
            bottom: true,
            color: sendingFeedback ? Colors.grey : null,
            onTap: () async {
              setState(() => sendingFeedback = true);
              try {
                await Future.delayed(const Duration(milliseconds: 300));

                if (await canLaunchUrl(Uri.parse(feedbackUrl))) {
                  await launchUrl(
                    Uri.parse(feedbackUrl),
                    mode: LaunchMode.externalApplication,
                  );
                }
              } finally {
                setState(() => sendingFeedback = false);
              }
            },
          ),
          const SizedBox(height: 24),
          SettingsItem(
            title: loggingOutLoading ? 'Logging out...' : 'Logout',
            icon: Icons.logout,
            top: true,
            bottom: true,
            color: loggingOutLoading ? Colors.grey : const Color(0xFFFF272A),
            onTap: () async {
              if (bloc == null) return;
              
              setState(() => loggingOutLoading = true);
              try {
                await bloc.logout();

                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/', 
                  (Route<dynamic> route) => false
                );
              } finally {
                setState(() => loggingOutLoading = false);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAssociationsSection() {
    final associations = _convertRolesToGroups();

    return associations.isEmpty
        ? const Center(child: Text('No Associations Found'))
        : Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // const SizedBox(height: 12),
                // Scrollable list of groups
                Expanded(
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: associations.length,
                    itemBuilder: (context, index) =>
                        _buildGroupCard(associations[index]),
                    separatorBuilder: (context, index) => const Padding(
                      padding: EdgeInsets.only(
                          left: 88, right: 16), // 56 avatar + 16 + 16 padding
                      child: Divider(
                        height: 0, // Makes divider flush with content
                        thickness: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
  }

  Widget _buildFollowingSection() {
    final following = _convertBodiesToGroups();

    return following.isEmpty
        ? const Center(child: Text('You are not following any groups'))
        : Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // const SizedBox(height: 12),
                // Scrollable list of groups
                Expanded(
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: following.length,
                    itemBuilder: (context, index) =>
                        _buildGroupCard(following[index]),
                    separatorBuilder: (context, index) => const Padding(
                      padding: EdgeInsets.only(
                          left: 88, right: 16), // 56 avatar + 16 + 16 padding
                      child: Divider(
                        height: 0, // Makes divider flush with content
                        thickness: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
  }

  Widget _buildGroupCard(Group group) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: InkWell(
        onTap: () {
          // Handle tap
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Group photo
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: group.photoUrl != null
                    ? DecorationImage(
                        image: NetworkImage(group.photoUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: group.photoUrl == null
                  ? const Icon(Icons.people, size: 24)
                  : null,
            ),
            const SizedBox(width: 16),
            // Group info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          group.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          group.about,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Group> _convertBodiesToGroups() {
    final groups = <Group>[];
    
    user?.userFollowedBodies?.forEach((body) {
      groups.add(Group(
        id: body.bodyID ?? UniqueKey().toString(),
        name: body.bodyName ?? "Unnamed Group",
        about: body.bodyShortDescription ?? "Followed organization",
        photoUrl: body.bodyImageURL,
      ));
    });
    
    return groups;
  }

  List<Group> _convertRolesToGroups() {
    final groups = <Group>[];

    user?.userRoles?.forEach((role) {
      groups.add(Group(
        id: role.roleID ?? UniqueKey().toString(),
        name: role.roleBodyDetails?.bodyName ?? 'Unnamed Group',
        about: role.roleBodyDetails?.bodyShortDescription ?? 'No description',
        photoUrl: role.roleBodyDetails?.bodyImageURL,
      ));
    });

    // user?.userFormerRoles?.forEach((role) {
    //   groups.add(Group(
    //     id: role.roleID ?? UniqueKey().toString(),
    //     name: role.roleBodyDetails?.bodyName ?? 'Former Group',
    //     about: role.roleBodyDetails?.bodyShortDescription ?? 'No description',
    //     photoUrl: role.roleBodyDetails?.bodyImageURL,
    //     isFormer: true,
    //   ));
    // });

    return groups;
  }
}

class Group {
  final String id;
  final String name;
  final String about;
  final String? photoUrl;
  final bool isFormer;

  const Group({
    required this.id,
    required this.name,
    required this.about,
    this.photoUrl,
    this.isFormer = false,
  });
}

// class UserPage extends StatefulWidget {
//   final User? initialUser;
//   final Future<User>? userFuture;

//   UserPage({this.userFuture, this.initialUser});

//   static void navigateWith(
//       BuildContext context, InstiAppBloc bloc, User? user) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         settings: RouteSettings(
//           name: "/user/${user?.userID ?? ""}",
//         ),
//         builder: (context) => UserPage(
//           initialUser: user,
//           userFuture: bloc.getUser(user?.userID ?? ""),
//         ),
//       ),
//     );
//   }

//   @override
//   _UserPageState createState() => _UserPageState();
// }

// class _UserPageState extends State<UserPage> {
//   GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
//   User? user;
//   Set<Event> sEvents = Set();
//   List<Event>? events = [];
//   Interest? _selectedInterest;
//   late bool editable;
//   List<Interest>? interests = [];

//   void onBodyChange(Interest? body) async {
//     var bloc = BlocProvider.of(context)?.bloc;
//     var res = await bloc?.achievementBloc.postInterest(body?.id ?? "", body!);
//     if (res != null) {
//       setState(() {
//         List<Interest>? k = interests;
//         k?.add(body!);
//         interests = k;
//       });
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         content: new Text('Error: Interest already exists'),
//         duration: new Duration(seconds: 10),
//       ));
//     }
//   }

//   bool cansee = false;

//   Widget _buildChips(BuildContext context) {
//     List<Widget> w = [];
//     var bloc = BlocProvider.of(context)?.bloc;
//     int length = interests?.length ?? 0;
//     for (int i = 0; i < length; i++) {
//       w.add(cansee
//           ? Chip(
//               labelPadding: EdgeInsets.all(2.0),
//               label: Text(
//                 interests?[i].title ?? "",
//                 style: TextStyle(
//                   color: Colors.white,
//                 ),
//               ),
//               backgroundColor:
//                   Colors.primaries[Random().nextInt(Colors.primaries.length)],
//               elevation: 6.0,
//               shadowColor: Colors.grey[60],
//               padding: EdgeInsets.all(8.0),
//               onDeleted: () async {
//                 await bloc?.achievementBloc
//                     .postDelInterest(interests![i].title!);
//                 interests?.removeAt(i);
//                 //_selected.removeAt(i);
//                 setState(() {
//                   interests = interests;
//                   //_selected = _selected;
//                 });
//               },
//             )
//           : Chip(
//               labelPadding: EdgeInsets.all(2.0),
//               label: Text(
//                 interests?[i].title ?? "",
//                 style: TextStyle(
//                   color: Colors.white,
//                 ),
//               ),
//               backgroundColor:
//                   Colors.primaries[Random().nextInt(Colors.primaries.length)],
//               elevation: 6.0,
//               shadowColor: Colors.grey[60],
//               padding: EdgeInsets.all(8.0),
//             ));
//       //w.add(_buildChip(interest.title, Colors.primaries[Random().nextInt(Colors.primaries.length)]));
//     }
//     return Wrap(
//       spacing: 8.0, // gap between adjacent chips
//       runSpacing: 4.0,
//       children: w,
//     );
//   }

//   Widget buildDropdownMenuItemsInterest(BuildContext context, Interest? body) {
//     // print("Entered build dropdown menu items");
//     if (body == null) {
//       return Container(
//         child: Text(
//           "Search for an interest",
//           style: Theme.of(context).textTheme.bodyLarge,
//         ),
//       );
//     }
//     // print(body);
//     return Container(
//       child: ListTile(
//         title: Text(body.title!),
//       ),
//     );
//   }

//   Widget _customPopupItemBuilderInterest(
//       BuildContext context, Interest body, bool isSelected) {
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 8),
//       decoration: !isSelected
//           ? null
//           : BoxDecoration(
//               border: Border.all(color: Theme.of(context).primaryColor),
//               borderRadius: BorderRadius.circular(5),
//               color: Colors.white,
//             ),
//       child: ListTile(
//         selected: isSelected,
//         title: Text(body.title!),
//       ),
//     );
//   }

//   @override
//   void initState() {
//     super.initState();

//     user = widget.initialUser;

//     //interests=[Interest(id:"123",title: "lll")];
//     widget.userFuture?.then((u) {
//       if (this.mounted) {
//         setState(() {
//           user = u;
//           interests = user?.interests!;
//         });
//       } else {
//         user = u;
//       }
//     });
//     WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
//       var bloc = BlocProvider.of(context)?.bloc;
//       bloc?.getUser("me").then((result) {
//         if (result.userLDAPId == widget.initialUser?.userLDAPId) {
//           setState(() {
//             cansee = true;
//           });
//         }
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     var bloc = BlocProvider.of(context)!.bloc;
//     var theme = Theme.of(context);
//     var footerButtons = <Widget>[];

//     if (user != null) {
//       sEvents.clear();
//       sEvents.addAll(user!.userGoingEvents ?? []);
//       sEvents.addAll(user!.userInterestedEvents ?? []);

//       events = user!.userGoingEvents != null ? sEvents.toList() : null;

//       if ((user!.userWebsiteURL ?? "") != "") {
//         footerButtons.add(IconButton(
//           tooltip: "Open website",
//           icon: Icon(Icons.language_outlined),
//           onPressed: () async {
//             if (user!.userWebsiteURL != null) {
//               if (await canLaunchUrl(Uri.parse(user!.userWebsiteURL!))) {
//                 await launchUrl(
//                   Uri.parse(user!.userWebsiteURL!),
//                   mode: LaunchMode.externalApplication,
//                 );
//               }
//             }
//           },
//         ));
//       }
//     }
//     return DefaultTabController(
//       initialIndex: 0,
//       length: 3,
//       child: Scaffold(
//         key: _scaffoldKey,
//         drawer: NavDrawer(),
//         bottomNavigationBar: MyBottomAppBar(
//           shape: RoundedNotchedRectangle(),
//           child: new Row(
//             mainAxisSize: MainAxisSize.max,
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: <Widget>[
//               IconButton(
//                 icon: Icon(
//                   Icons.menu_outlined,
//                   semanticLabel: "Show navigation drawer",
//                 ),
//                 onPressed: () {
//                   _scaffoldKey.currentState?.openDrawer();
//                 },
//               ),
//             ],
//           ),
//         ),
//         body: SafeArea(
//           child: user == null
//               ? Center(
//                   child: CircularProgressIndicatorExtended(
//                   label: Text("Loading the user page"),
//                 ))
//               : NestedScrollView(
//                   headerSliverBuilder:
//                       (BuildContext context, bool innerBoxIsScrolled) {
//                     return <Widget>[
//                       SliverToBoxAdapter(
//                         child: TitleWithBackButton(
//                           contentPadding: const EdgeInsets.symmetric(
//                               vertical: 28.0, horizontal: 12.0),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: <Widget>[
//                               ListTile(
//                                 leading: NullableCircleAvatar(
//                                   user!.userProfilePictureUrl ?? "",
//                                   Icons.person_outline_outlined,
//                                   radius: 48,
//                                   heroTag: user!.userID ?? "",
//                                   photoViewable: true,
//                                 ),
//                                 title: Text(
//                                   user!.userName ?? "",
//                                   style: theme.textTheme.headlineSmall
//                                       ?.copyWith(
//                                           fontFamily: theme.textTheme
//                                               .displaySmall?.fontFamily),
//                                 ),
//                                 subtitle: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: <Widget>[
//                                     user!.userRollNumber != null
//                                         ? Text(user!.userRollNumber ?? "",
//                                             style: theme.textTheme.titleLarge)
//                                         : CircularProgressIndicatorExtended(
//                                             size: 12,
//                                             label: Text("Loading Roll Number"),
//                                           ),
//                                   ]
//                                     ..addAll(user!.userEmail != null &&
//                                             !user!.userEmail!
//                                                 .toLowerCase()
//                                                 .contains("n/a")
//                                         ? [
//                                             InkWell(
//                                               onTap: user!.userEmail != null
//                                                   ? () => _launchEmail(context)
//                                                   : null,
//                                               child: Tooltip(
//                                                 message: "E-mail this person",
//                                                 child: user!.userEmail != null
//                                                     ? Text(user!.userEmail!,
//                                                         style: theme.textTheme
//                                                             .titleLarge
//                                                             ?.copyWith(
//                                                                 color: Colors
//                                                                     .lightBlue))
//                                                     : CircularProgressIndicatorExtended(
//                                                         size: 12,
//                                                         label: Text(
//                                                             "Loading email"),
//                                                       ),
//                                               ),
//                                             ),
//                                           ]
//                                         : [])
//                                     ..addAll(user!.userContactNumber != null &&
//                                             !user!.userContactNumber!
//                                                 .toLowerCase()
//                                                 .contains("n/a")
//                                         ? [
//                                             InkWell(
//                                               onTap: () =>
//                                                   _launchDialer(context),
//                                               child: Tooltip(
//                                                 message: "Call this person",
//                                                 child: Text(
//                                                     user!.userContactNumber!,
//                                                     style: theme
//                                                         .textTheme.titleLarge
//                                                         ?.copyWith(
//                                                             color: Colors
//                                                                 .lightBlue)),
//                                               ),
//                                             )
//                                           ]
//                                         : []),
//                                 ),
//                               ),
//                               Column(
//                                   mainAxisAlignment: MainAxisAlignment.start,
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Container(
//                                         // width: double.infinity,
//                                         margin: EdgeInsets.fromLTRB(
//                                             15.0, 0.0, 15.0, 10.0),
//                                         child: Column(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.center,
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.center,
//                                             children: <Widget>[
//                                               SizedBox(
//                                                 height: 20.0,
//                                               ),

//                                               cansee
//                                                   ? CustomDropdown<Interest>(
//                                                       emptyText:
//                                                           "No interests found. Refine your search!",
//                                                       onChanged: onBodyChange,
//                                                       label: "Interests",
//                                                       itemBuilder:
//                                                           _customPopupItemBuilderInterest,
//                                                       asyncItems: bloc
//                                                           .achievementBloc
//                                                           .searchForInterest,
//                                                       dropdownBuilder:
//                                                           buildDropdownMenuItemsInterest,
//                                                       style: theme.textTheme
//                                                           .titleMedium,
//                                                       validator: (value) {
//                                                         if (value == null) {
//                                                           return 'Please select a organization';
//                                                         }
//                                                         return null;
//                                                       },
//                                                       selectedItem:
//                                                           _selectedInterest,
//                                                     )
//                                                   : SizedBox(),
//                                               _buildChips(context),
//                                               //_buildChip('Gamer', Color(0xFFff6666))
//                                               // SizedBox(
//                                               // height: this.selectedB
//                                               // ? 20.0
//                                               //     : 0,
//                                               // ),
//                                               // BodyCard(
//                                               // thing:
//                                               // this._selectedBody,
//                                               // selected:
//                                               // this.selectedB),
//                                               //_buildEvent(theme, bloc, snapshot.data[0]);//verify_card(thing: this._selectedCompany, selected: this.selected);
//                                             ])),
//                                   ]),
//                             ],
//                           ),
//                         ),
//                       ),
//                       SliverPersistentHeader(
//                         floating: true,
//                         pinned: true,
//                         delegate: _SliverTabBarDelegate(
//                           child: PreferredSize(
//                             preferredSize: Size.fromHeight(72),
//                             child: Material(
//                               elevation: 4.0,
//                               child: TabBar(
//                                 labelColor: theme.colorScheme.secondary,
//                                 unselectedLabelColor: theme.disabledColor,
//                                 tabs: [
//                                   Tab(
//                                       text: "Associations",
//                                       icon: Icon(Icons.work_outline_outlined)),
//                                   Tab(
//                                       text: "Following",
//                                       icon:
//                                           Icon(Icons.people_outline_outlined)),
//                                   Tab(
//                                       text: "Events",
//                                       icon: Icon(Icons.event_outlined)),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ];
//                   },
//                   body: TabBarView(
//                     // These are the contents of the tab views, below the tabs.
//                     children:
//                         ["Associations", "Following", "Events"].map((name) {
//                       return SafeArea(
//                         top: false,
//                         bottom: false,
//                         child: Builder(
//                           // This Builder is needed to provide a BuildContext that is "inside"
//                           // the NestedScrollView, so that sliverOverlapAbsorberHandleFor() can
//                           // find the NestedScrollView.
//                           builder: (BuildContext context) {
//                             var delegates = {
//                               "Associations": SliverChildBuilderDelegate(
//                                 (BuildContext context, int index) {
//                                   return user!.userRoles != null
//                                       ? (index >= (user!.userRoles?.length ?? 0)
//                                           ? _buildFormerRoleTile(
//                                               bloc,
//                                               theme.textTheme,
//                                               user!.userFormerRoles![index -
//                                                   (user!.userRoles?.length ??
//                                                       0)])
//                                           : _buildRoleTile(
//                                               bloc,
//                                               theme.textTheme,
//                                               user!.userRoles![index]))
//                                       : Padding(
//                                           padding: EdgeInsets.all(8.0),
//                                           child:
//                                               CircularProgressIndicatorExtended(
//                                             label: Text("Loading associations"),
//                                           ));
//                                 },
//                                 childCount: (user!.userRoles?.length ?? 1) +
//                                     (user!.userFormerRoles?.length ?? 0),
//                               ),
//                               "Following": SliverChildBuilderDelegate(
//                                 (BuildContext context, int index) {
//                                   return user!.userFollowedBodies != null
//                                       ? _buildBodyTile(bloc, theme.textTheme,
//                                           user!.userFollowedBodies![index])
//                                       : Padding(
//                                           padding: EdgeInsets.all(8.0),
//                                           child:
//                                               CircularProgressIndicatorExtended(
//                                             label: Text(
//                                                 "Loading following bodies"),
//                                           ));
//                                 },
//                                 childCount:
//                                     user!.userFollowedBodies?.length ?? 1,
//                               ),
//                               "Events": SliverChildBuilderDelegate(
//                                 (BuildContext context, int index) {
//                                   return events != null
//                                       ? _buildEventTile(
//                                           bloc, events![index], theme)
//                                       : Padding(
//                                           padding: EdgeInsets.all(8.0),
//                                           child:
//                                               CircularProgressIndicatorExtended(
//                                             label: Text(
//                                                 "Loading following events"),
//                                           ));
//                                 },
//                                 childCount: events?.length ?? 1,
//                               ),
//                             };
//                             return CustomScrollView(
//                               // The "controller" and "primary" members should be left
//                               // unset, so that the NestedScrollView can control this
//                               // inner scroll view.
//                               // If the "controller" property is set, then this scroll
//                               // view will not be associated with the NestedScrollView.
//                               // The PageStorageKey should be unique to this ScrollView;
//                               // it allows the list to remember its scroll position when
//                               // the tab view is not on the screen.
//                               key: PageStorageKey<String>(name),
//                               slivers: <Widget>[
//                                 // SliverOverlapInjector(
//                                 //   // This is the flip side of the SliverOverlapAbsorber above.
//                                 //   handle: NestedScrollView
//                                 //       .sliverOverlapAbsorberHandleFor(context),
//                                 // ),
//                                 SliverPadding(
//                                   padding: const EdgeInsets.all(8.0),
//                                   // In this example, the inner scroll view has
//                                   // fixed-height list items, hence the use of
//                                   // SliverFixedExtentList. However, one could use any
//                                   // sliver widget here, e.g. SliverList or SliverGrid.
//                                   sliver: delegates[name]?.childCount == 0
//                                       ? SliverToBoxAdapter(
//                                           child: Center(
//                                             child: Padding(
//                                               padding:
//                                                   const EdgeInsets.all(8.0),
//                                               child: Text(
//                                                 "No $name",
//                                               ),
//                                             ),
//                                           ),
//                                         )
//                                       : SliverList(
//                                           delegate: delegates[name]!,
//                                         ),
//                                 ),
//                               ],
//                             );
//                           },
//                         ),
//                       );
//                     }).toList(),
//                   ),
//                 ),
//         ),
//         floatingActionButton: user == null
//             ? null
//             : FloatingActionButton(
//                 child: Icon(Icons.share_outlined),
//                 tooltip: "Share this person's profile",
//                 onPressed: () async {
//                   await Share.share(
//                       "Check this cool person: ${ShareURLMaker.getUserURL(user!)}");
//                 },
//               ),
//         floatingActionButtonLocation: footerButtons.isEmpty
//             ? FloatingActionButtonLocation.endDocked
//             : FloatingActionButtonLocation.endFloat,
//         persistentFooterButtons:
//             footerButtons.isNotEmpty ? footerButtons : null,
//       ),
//     );
//   }

//   Widget _buildEventTile(InstiAppBloc bloc, Event event, ThemeData theme) {
//     return ListTile(
//       title: Text(
//         event.eventName ?? "",
//         style: theme.textTheme.titleLarge,
//       ),
//       enabled: true,
//       leading: NullableCircleAvatar(
//         event.eventImageURL ?? event.eventBodies?[0].bodyImageURL ?? "",
//         Icons.event_outlined,
//         heroTag: event.eventID ?? "",
//       ),
//       subtitle: Text(event.getSubTitle()),
//       onTap: () {
//         EventPage.navigateWith(context, bloc, event);
//       },
//     );
//   }

//   Widget _buildBodyTile(InstiAppBloc bloc, TextTheme theme, Body body) {
//     return ListTile(
//       title: Text(body.bodyName ?? "", style: theme.titleLarge),
//       subtitle: Text(body.bodyShortDescription ?? "", style: theme.titleSmall),
//       leading: NullableCircleAvatar(
//         body.bodyImageURL ?? "",
//         Icons.people_outline_outlined,
//         heroTag: body.bodyID ?? "",
//       ),
//       onTap: () {
//         BodyPage.navigateWith(context, bloc, body: body);
//       },
//     );
//   }

//   Widget _buildRoleTile(InstiAppBloc bloc, TextTheme theme, Role role) {
//     return ListTile(
//       title:
//           Text(role.roleBodyDetails?.bodyName ?? "", style: theme.titleLarge),
//       subtitle: Text(role.roleName ?? "", style: theme.titleSmall),
//       leading: NullableCircleAvatar(
//         role.roleBodyDetails?.bodyImageURL ?? "",
//         Icons.people_outline_outlined,
//         heroTag: role.roleID ?? role.roleBodyDetails?.bodyID ?? "",
//       ),
//       onTap: () {
//         BodyPage.navigateWith(context, bloc, role: role);
//       },
//     );
//   }

//   Widget _buildFormerRoleTile(InstiAppBloc bloc, TextTheme theme, Role role) {
//     return ListTile(
//       title:
//           Text(role.roleBodyDetails?.bodyName ?? "", style: theme.titleLarge),
//       subtitle: Text("Former ${role.roleName} ${role.year ?? ""}",
//           style: theme.titleSmall),
//       leading: NullableCircleAvatar(
//         role.roleBodyDetails?.bodyImageURL ?? "",
//         Icons.people_outline_outlined,
//         heroTag: role.roleID ?? role.roleBodyDetails?.bodyID ?? "",
//       ),
//       onTap: () {
//         BodyPage.navigateWith(context, bloc, role: role);
//       },
//     );
//   }

//   _launchEmail(BuildContext context) async {
//     var url = "mailto:${user?.userEmail}?subject=Let's Have Coffee";
//     if (await canLaunchUrl(Uri.parse(url))) {
//       await launchUrl(
//         Uri.parse(url),
//         mode: LaunchMode.externalApplication,
//       );
//     } else {
//       ScaffoldMessenger.of(context)
//         ..hideCurrentSnackBar()
//         ..showSnackBar(
//           SnackBar(
//             content: Text("Mail app failed to open"),
//           ),
//         );
//     }
//   }

//   _launchDialer(BuildContext context) async {
//     var url = "tel:${user?.userContactNumber}";
//     if (await canLaunchUrl(Uri.parse(url))) {
//       await launchUrl(
//         Uri.parse(url),
//         mode: LaunchMode.externalApplication,
//       );
//     } else {
//       ScaffoldMessenger.of(context)
//         ..hideCurrentSnackBar()
//         ..showSnackBar(
//           SnackBar(
//             content: Text("Phone app failed to open"),
//           ),
//         );
//     }
//   }
// }

// class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
//   final PreferredSize child;

//   _SliverTabBarDelegate({required this.child});

//   @override
//   Widget build(
//       BuildContext context, double shrinkOffset, bool overlapsContent) {
//     return child;
//   }

//   @override
//   double get maxExtent => child.preferredSize.height;

//   @override
//   double get minExtent => child.preferredSize.height;

//   @override
//   bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
//     return false;
//   }
// }
