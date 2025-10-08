import 'dart:async';
import 'package:InstiApp/src/api/model/user.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:InstiApp/src/widgets/appbar.dart';
import 'package:InstiApp/src/widgets/buttons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:InstiApp/src/utils/responsive.dart';
import 'package:InstiApp/src/routes/aboutpage.dart';

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
        Tab(text: 'General', height: RS.sh(context, 64)),
        Tab(text: 'Associations', height: RS.sh(context, 64)),
        Tab(text: 'Following', height: RS.sh(context, 64)),
      ];
    } else {
      return [
        Tab(text: 'Associations', height: RS.sh(context, 64)),
        Tab(text: 'Following', height: RS.sh(context, 64)),
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

  Widget _buildPortraitLayout() {
    final isGeneralTab = _tabController!.length == 3 && _tabController!.index == 0;
    final tabCount = _tabController!.length;

    return Column(
      children: [
        SizedBox(height: RS.sh(context, 4)),
        CustomAppBar(
          title: 'Profile',
          onOther: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AboutPage()),
            );
          },
        ),
        SizedBox(height: RS.sh(context, 24)),
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
                labelColor: Color.fromRGBO(15, 22, 32, 0.8),
                labelStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'DM Sans'),
                labelPadding: EdgeInsets.all(0),
                unselectedLabelColor: Color.fromRGBO(15, 22, 32, 0.8),
                unselectedLabelStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'DM Sans'),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorWeight: 3,
                indicatorColor: Color.fromRGBO(48, 111, 220, 1),
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
    );
  }

  Widget _buildLandscapeLayout() {
    final tabCount = _tabController!.length;

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: RS.sh(context, 4)),
          CustomAppBar(
            title: 'Profile',
            onOther: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AboutPage()),
              );
            },
          ),
          SizedBox(height: RS.sh(context, 24)),
          // In landscape, always show compact profile card for consistency
          cansee ? _buildCompactProfileCard() : _spectatingProfileCard(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  labelColor: Color.fromRGBO(15, 22, 32, 0.8),
                  labelStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'DM Sans'),
                  labelPadding: EdgeInsets.all(0),
                  unselectedLabelColor: Color.fromRGBO(15, 22, 32, 0.8),
                  unselectedLabelStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'DM Sans'),
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorWeight: 3,
                  indicatorColor: Color.fromRGBO(48, 111, 220, 1),
                  tabs: _buildTabs(tabCount)
                ),
              ],
            ),
          ),
          // In landscape, show the tab content directly (not in TabBarView)
          _buildCurrentTabContent(),
          SizedBox(height: RS.sh(context, 24)), // Add some bottom padding
        ],
      ),
    );
  }

  Widget _buildCurrentTabContent() {
    final tabCount = _tabController!.length;
    final currentIndex = _tabController!.index;
    
    if (tabCount == 3) {
      // Current user view (3 tabs)
      switch (currentIndex) {
        case 0:
          return _buildSettingsSection();
        case 1:
          return _buildAssociationsSection(scrollable: false);
        case 2:
          return _buildFollowingSection(scrollable: false);
        default:
          return Container();
      }
    } else {
      // Spectator view (2 tabs)
      switch (currentIndex) {
        case 0:
          return _buildAssociationsSection(scrollable: false);
        case 1:
          return _buildFollowingSection(scrollable: false);
        default:
          return Container();
      }
    }
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
      backgroundColor: Color.fromRGBO(246, 246, 246, 1),
      body: SafeArea(
        child: user == null
            ? Center(
                child: CircularProgressIndicatorExtended(
                    label: Text("Loading the User Page")))
            : OrientationBuilder(
                builder: (context, orientation) {
                  return orientation == Orientation.portrait
                      ? _buildPortraitLayout()
                      : _buildLandscapeLayout();
                },
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
                width: RS.s(context, 80),
                height: RS.s(context, 80),
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
                        color: Color.fromRGBO(239, 239, 239, 1),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 16),

              // Small Logo
              SizedBox(
                width: RS.s(context, 50),
                height: RS.s(context, 50),
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
                width: RS.sw(context, 88),
                child: Center(
                  child: Container(
                    width: RS.sw(context, 88),
                    height: RS.sh(context, 107), // match your original height
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
                                  color: Color.fromRGBO(255, 255, 255, 0.9),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                user?.userRollNumber ?? 'Loading...',
                                textHeightBehavior: TextHeightBehavior(
                                  applyHeightToFirstAscent: false,
                                  applyHeightToLastDescent: false,
                                ),
                                style: TextStyle(
                                  color: Color.fromRGBO(255, 255, 255, 0.9),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Small Logo
                        SizedBox(
                          width: RS.s(context, 35),
                          height: RS.s(context, 35),
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
                        child: _buildRollNumberBarcode(height: RS.sh(context, 50)),
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
                      width: RS.sw(context, 98),
                      height: RS.sh(context, 120),
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
                            'Programme', user?.degree ?? '-', 14),
                        _buildProfileInfoItem(
                          'Department',
                          user?.department ?? '-',
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
                            width: RS.sw(context, 51),
                            height: RS.sh(context, 50),
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
                      _buildProfileInfoItem('Validity', user?.graduationYear ?? '-', 14),
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
                    child: _buildRollNumberBarcode(height: RS.sh(context, 72)),
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
            color: Colors.white.withOpacity(0.3),
            fontSize: 10,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 2,),
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
        height: height ?? RS.sh(context, 50),
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
      height: height ?? RS.sh(context, 50),
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
            icon: Icons.notifications_none_outlined,
          ),
          // SettingsItem(
          //   title: 'Settings',
          //   icon: Icons.settings_outlined,
          //   onTap: () {
          //     Navigator.pushNamed(context, '/settings');
          //   },
          // ),
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
            color: loggingOutLoading ? Colors.grey : Color.fromRGBO(237, 0, 51, 1),
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

  Widget _buildAssociationsSection({bool scrollable = true}) {
    final associations = _convertRolesToGroups();

    return associations.isEmpty
        ? const Center(child: Text('No Associations Found'))
        : Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (scrollable)
                  Expanded(
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: associations.length,
                      itemBuilder: (context, index) =>
                          _buildGroupCard(associations[index]),
                      separatorBuilder: (context, index) => Padding(
                        padding: EdgeInsets.only(
                            left: RS.sh(context, 88), right: 16),
                      ),
                    ),
                  )
                else
                  Column(
                    children: [
                      for (int index = 0; index < associations.length; index++)
                        Column(
                          children: [
                            _buildGroupCard(associations[index]),
                            if (index < associations.length - 1)
                              Padding(
                                padding: EdgeInsets.only(
                                    left: RS.sh(context, 88), right: 16),
                              ),
                          ],
                        ),
                    ],
                  ),
              ],
            ),
          );
  }

  Widget _buildFollowingSection({bool scrollable = true}) {
    final following = _convertBodiesToGroups();

    return following.isEmpty
        ? const Center(child: Text('You are not following any groups'))
        : Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (scrollable)
                  Expanded(
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: following.length,
                      itemBuilder: (context, index) =>
                          _buildGroupCard(following[index]),
                      separatorBuilder: (context, index) => Padding(
                        padding: EdgeInsets.only(
                            left: RS.sh(context, 88), right: 16),
                      ),
                    ),
                  )
                else
                  Column(
                    children: [
                      for (int index = 0; index < following.length; index++)
                        Column(
                          children: [
                            _buildGroupCard(following[index]),
                            if (index < following.length - 1)
                              Padding(
                                padding: EdgeInsets.only(
                                    left: RS.sh(context, 88), right: 16),
                              ),
                          ],
                        ),
                    ],
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
              width: RS.s(context, 64),
              height: RS.s(context, 64),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Color.fromRGBO(210, 213, 218, 1), width: 1),
                image: group.photoUrl != null
                    ? DecorationImage(
                        image: NetworkImage(group.photoUrl!),
                        fit: BoxFit.contain,
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          group.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color.fromRGBO(15, 22, 32, 1)
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
                            color: Color.fromRGBO(15, 22, 32, 1),
                            fontWeight: FontWeight.w400
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