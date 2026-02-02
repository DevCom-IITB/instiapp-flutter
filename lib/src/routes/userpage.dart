import 'dart:async';
import 'package:InstiApp/src/api/model/body.dart';
import 'package:InstiApp/src/api/model/user.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:InstiApp/src/widgets/appbar.dart';
import 'package:InstiApp/src/widgets/buttons.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:InstiApp/src/utils/responsive.dart';
import 'package:InstiApp/src/routes/aboutpage.dart';
import 'package:InstiApp/src/routes/bodypage.dart';

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

class _UserPageState extends State<UserPage> with TickerProviderStateMixin {
  // Changed to TickerProviderStateMixin
  User? user;
  bool cansee = false;
  TabController? _tabController;
  bool NotificationVisibility = true;
  List<Group> associations = [];
  List<Group> following = [];
  bool loggingOutLoading = false;
  bool updatingProfile = false;
  bool sendingFeedback = false;
  bool _isLoading = false;
  bool _loadFailed = false;
  bool _isGuest = false;
  bool _initialized = false;
  InstiAppBloc? _bloc;

  final String updateProfileUrl = "https://gymkhana.iitb.ac.in/sso/user";
  final String feedbackUrl = "https://insti.app/feedback";

  @override
  void initState() {
    super.initState();

    // Use cached data immediately
    user = widget.initialUser;

    // Initialize with basic data (no bloc access yet)
    _initializeBasicData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      _bloc = BlocProvider.of(context)?.bloc;
      _initializeWithBloc();
    }
  }

  void _initializeBasicData() {
    // Initialize with whatever data we have immediately (without bloc)
    if (user != null) {
      associations = _convertRolesToGroups();
      following = _convertBodiesToGroups();
    }
  }

  void _initializeWithBloc() {
    if (_bloc == null) {
      _isGuest = true;
      cansee = false;
      _initialized = true;
      _createTabController(); // Create tab controller even for guests
      return;
    }

    // Determine if viewing own profile using cached session
    _checkIfViewingOwnProfileFromCache();

    // Create tab controller based on permissions
    _createTabController();

    _initialized = true;

    // Try to load fresh data in background
    _loadUserData();
  }

  void _createTabController() {
    // Dispose old controller if exists
    if (_tabController != null) {
      _tabController!.dispose();
    }

    // Create new controller based on current cansee state
    final length = cansee ? 3 : 2;
    _tabController = TabController(length: length, vsync: this);
    _tabController?.addListener(_handleTabChange);
  }

  void _checkIfViewingOwnProfileFromCache() {
    if (_bloc == null) {
      _isGuest = true;
      cansee = false;
      return;
    }

    // Check if user is guest (no session)
    if (_bloc!.currSession == null) {
      _isGuest = true;
      cansee = false;
      return;
    }

    // User is not guest, we have a session
    _isGuest = false;

    if (user == null) {
      cansee = false;
      return;
    }

    // Method 1: Check against session's current user profile (cached)
    final currentUserFromSession = _bloc!.currSession?.profile;
    if (currentUserFromSession != null) {
      // Compare by userID first (most reliable)
      if (currentUserFromSession.userID != null && user!.userID != null) {
        cansee = currentUserFromSession.userID == user!.userID;
        if (cansee) return;
      }

      // Compare by LDAP ID as fallback
      if (currentUserFromSession.userLDAPId != null &&
          user!.userLDAPId != null) {
        cansee = currentUserFromSession.userLDAPId == user!.userLDAPId;
        if (cansee) return;
      }

      // For "me" endpoint navigation
      if (user!.userID == "me" || widget.userFuture == null) {
        cansee = true;
        return;
      }
    }

    // Method 2: Check if session ID matches user ID
    if (_bloc!.currSession?.profileId != null && user!.userID != null) {
      cansee = _bloc!.currSession?.profileId == user!.userID;
      if (cansee) return;
    }

    // Method 3: Check session user ID
    if (_bloc!.currSession?.user != null && user!.userID != null) {
      cansee = _bloc!.currSession?.user == user!.userID;
      if (cansee) return;
    }

    // Default to false if we can't verify
    cansee = false;
  }

  void _handleTabChange() {
    if (mounted) setState(() {});
  }

  Future<void> _loadUserData() async {
    if (!mounted || _bloc == null) return;

    setState(() {
      _isLoading = true;
      _loadFailed = false;
    });

    try {
      // Try to load fresh user data
      if (widget.userFuture != null) {
        final u = await widget.userFuture!;
        if (mounted) {
          setState(() {
            user = u; // Update with fresh data
            associations = _convertRolesToGroups();
            following = _convertBodiesToGroups();
          });
        }
      } else {
        // If no future provided (viewing "me" without cached data)
        // Try to get current user from bloc
        if (_bloc!.currSession?.profile != null && user == null) {
          if (mounted) {
            setState(() {
              user = _bloc!.currSession?.profile;
              associations = _convertRolesToGroups();
              following = _convertBodiesToGroups();
            });
          }
        }
      }

      // Verify if viewing own profile with fresh data (only if not guest)
      if (!_isGuest) {
        await _verifyOwnProfileWithFreshData();
      }
    } catch (e) {
      // If loading fails, keep cached data but mark as failed
      if (mounted) {
        setState(() {
          _loadFailed = true;
        });
      }
      print("Failed to load fresh user data: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _verifyOwnProfileWithFreshData() async {
    if (_bloc == null || user == null || _isGuest) return;

    try {
      // Try to get fresh current user data
      final currentUser = await _bloc!.getUser("me");
      if (mounted) {
        bool newCansee = (currentUser.userID != null &&
                user!.userID != null &&
                currentUser.userID == user!.userID) ||
            (currentUser.userLDAPId != null &&
                user!.userLDAPId != null &&
                currentUser.userLDAPId == user!.userLDAPId);

        // Only update if cansee state changed
        if (newCansee != cansee) {
          setState(() {
            cansee = newCansee;
            _createTabController(); // Recreate tab controller with new length
          });
        }
      }
    } catch (e) {
      // If we can't verify with fresh data, keep the cached assumption
      // Don't update cansee state - keep what we determined from cache
      print("Failed to verify current user, using cached: $e");
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
    _tabController?.dispose();
    super.dispose();
  }

  Widget _buildPortraitLayout() {
    if (_tabController == null) {
      return Center(
        child:
            CircularProgressIndicatorExtended(label: Text("Loading tabs...")),
      );
    }

    final isGeneralTab =
        _tabController!.length == 3 && _tabController!.index == 0;
    final tabCount = _tabController!.length;

    return Column(
      children: [
        SizedBox(height: RS.sh(context, 4)),
        CustomAppBar(
          title: 'Profile',
          // onOther: () {
          //   Navigator.push(
          //     context,
          //     MaterialPageRoute(builder: (context) => AboutPage()),
          //   );
          // },
        ),
        SizedBox(height: RS.sh(context, 24)),
        if (_isLoading && user != null)
          LinearProgressIndicator(
            backgroundColor: Colors.transparent,
            minHeight: 2,
          ),

        // Show appropriate profile card
        if (_isGuest)
          _buildGuestProfileCard()
        else if (cansee)
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: isGeneralTab
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: _buildProfileCard(),
            secondChild: _buildCompactProfileCard(),
          )
        else
          _spectatingProfileCard(),

        if (_loadFailed)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Showing cached data. Some information may be outdated.',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              TabBar(
                  controller: _tabController,
                  labelColor: const Color.fromRGBO(48, 111, 220, 1),
                  labelStyle: TextStyle(
                      fontSize: RS.sp(context, 18),
                      fontWeight: FontWeight.w700,
                      fontFamily: 'DM Sans'),
                  labelPadding: EdgeInsets.all(0),
                  unselectedLabelColor: Color.fromRGBO(15, 22, 32, 0.8),
                  unselectedLabelStyle: TextStyle(
                      fontSize: RS.sp(context, 18),
                      fontWeight: FontWeight.w400,
                      fontFamily: 'DM Sans'),
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorWeight: 3,
                  indicatorColor: Color.fromRGBO(48, 111, 220, 1),
                  tabs: _buildTabs(tabCount)),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
              controller: _tabController, children: _buildTabViews(tabCount)),
        ),
      ],
    );
  }

  Widget _buildGuestProfileCard() {
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_outline_outlined,
                size: RS.s(context, 60),
                color: Colors.white,
              ),
              SizedBox(height: 16),
              Text(
                'Guest Mode',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: RS.sp(context, 24),
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Login to view profiles',
                style: TextStyle(
                  color: Color.fromRGBO(239, 239, 239, 1),
                  fontSize: RS.sp(context, 14),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLandscapeLayout() {
    if (_tabController == null) {
      return Center(
        child:
            CircularProgressIndicatorExtended(label: Text("Loading tabs...")),
      );
    }

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
          if (_isLoading && user != null)
            LinearProgressIndicator(
              backgroundColor: Colors.transparent,
              minHeight: 2,
            ),

          // Show appropriate profile card
          if (_isGuest)
            _buildGuestProfileCard()
          else if (cansee)
            _buildCompactProfileCard()
          else
            _spectatingProfileCard(),

          if (_loadFailed)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Showing cached data. Some information may be outdated.',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
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
                    tabs: _buildTabs(tabCount)),
              ],
            ),
          ),
          _buildCurrentTabContent(),
          SizedBox(height: RS.sh(context, 24)),
        ],
      ),
    );
  }

  Widget _buildCurrentTabContent() {
    if (_tabController == null) return Container();

    final tabCount = _tabController!.length;
    final currentIndex = _tabController!.index;

    if (tabCount == 3) {
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
    return Scaffold(
      backgroundColor: Color.fromRGBO(246, 246, 246, 1),
      body: SafeArea(
        child: !_initialized && _isLoading && user == null
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

    if (profileUrl == null || profileUrl.isEmpty) {
      return Icon(
        Icons.person_outline_outlined,
        size: RS.s(context, 50),
        color: Colors.grey,
      );
    }

    return Image.network(
      profileUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(child: CircularProgressIndicator());
      },
      errorBuilder: (context, error, stackTrace) => Icon(
        Icons.person_outline_outlined,
        size: RS.s(context, 50),
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
                        fontSize: RS.sp(context, 24),
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
                        fontSize: RS.sp(context, 14),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
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
              SizedBox(
                width: RS.sw(context, 88),
                child: Center(
                  child: Container(
                    width: RS.sw(context, 88),
                    height: RS.sh(context, 107),
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
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
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
                                  fontSize: RS.sp(context, 16),
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
                                  fontSize: RS.sp(context, 16),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: RS.s(context, 35),
                          height: RS.s(context, 35),
                          child: Center(
                            child: Image.asset(
                              'assets/profilepage/logo.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(
                                Icons.school,
                                size: RS.s(context, 35),
                                color: Colors.white54,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: EdgeInsets.all(6),
                      margin: EdgeInsets.only(bottom: 4),
                      child: ClipRRect(
                        child:
                            _buildRollNumberBarcode(height: RS.sh(context, 50)),
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
                        child: _buildProfileImage(),
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
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(
                                  Icons.school,
                                  size: RS.s(context, 35),
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
                      _buildProfileInfoItem(
                          'Validity', user?.graduationYear ?? '-', 14),
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
            fontSize: RS.sp(context, 10),
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(
          height: 2,
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: RS.sp(context, fsize),
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

  Widget _settingsContent() {
    // SECURITY CHECK
    if (!cansee || _isGuest) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.lock_outline, size: 48, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Access restricted',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

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
          SizedBox(height: RS.sh(context, 24)),
          SettingsItem(
            title: loggingOutLoading ? 'Logging out...' : 'Logout',
            icon: Icons.logout,
            top: true,
            bottom: true,
            color: loggingOutLoading
                ? Colors.grey
                : const Color.fromRGBO(237, 0, 51, 1),
            onTap: () async {
              if (_bloc == null) return;

              setState(() => loggingOutLoading = true);
              try {
                await _bloc!.logout();
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/',
                  (Route<dynamic> route) => false,
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

  Widget _buildSettingsSection({bool scrollable = true}) {
    if (scrollable) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: _settingsContent(),
      );
    }

    return _settingsContent();
  }

  Widget _buildAssociationsSection({bool scrollable = true}) {
    if (associations.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          // child: Text(
          //   'No Associations Found',
          //   style: TextStyle(color: Colors.grey),
          // ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                'assets/profilepage/ghost.svg',
                width: 280,
                height: 280,
                fit: BoxFit.contain,
              ),
              // SizedBox(height: responsive.h(5)),
              Text(
                'No Associations Found',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  fontFamily: 'DM Sans',
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
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
                  padding: EdgeInsets.only(left: RS.sw(context, 88), right: 16),
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
                              left: RS.sw(context, 88), right: 16),
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
    if (following.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                'assets/profilepage/ghost.svg',
                width: 280,
                height: 280,
                fit: BoxFit.contain,
              ),
              // SizedBox(height: responsive.h(5)),
              Text(
                "You aren't following any clubs",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  fontFamily: 'DM Sans',
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
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
                  padding: EdgeInsets.only(left: RS.sw(context, 88), right: 16),
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
                              left: RS.sw(context, 88), right: 16),
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
          BodyPage.navigateWith(context, _bloc!,
              body: Body(
                  bodyID: group.bodyId,
                  bodyName: group.name,
                  bodyShortDescription: group.about,
                  bodyImageURL: group.photoUrl));
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: RS.s(context, 64),
              height: RS.s(context, 64),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                // border: Border.all(color: Color.fromRGBO(210, 213, 218, 1), width: 1),
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
            SizedBox(width: RS.sw(context, 16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          group.name,
                          style: TextStyle(
                              fontSize: RS.sp(context, 20),
                              fontWeight: FontWeight.w600,
                              color: Color.fromRGBO(15, 22, 32, 1)),
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
                              fontSize: RS.sp(context, 14),
                              color: Color.fromRGBO(15, 22, 32, 1),
                              fontWeight: FontWeight.w400),
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
      if (body.bodyID == null) return;

      groups.add(Group(
        bodyId: body.bodyID!,
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
      final body = role.roleBodyDetails;
      if (body?.bodyID == null) return;

      groups.add(Group(
        bodyId: body!.bodyID!,
        name: body.bodyName ?? 'Unnamed Group',
        about: body.bodyShortDescription ?? 'No description',
        photoUrl: body.bodyImageURL,
      ));
    });

    return groups;
  }
}

class Group {
  final String bodyId;
  final String name;
  final String about;
  final String? photoUrl;
  final bool isFormer;

  const Group({
    required this.bodyId,
    required this.name,
    required this.about,
    this.photoUrl,
    this.isFormer = false,
  });
}
