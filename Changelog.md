# Changelog

## Unreleased

## 2.4.1

- Move map page outside utilities
- Implement deep links for map page
- Fix Android 11+ url open issue
- Remove Google Maps library (due to iOS limitations)

## 2.4.0

- Implement Buy and Sell

## 2.3.0

- Revert 5 year b'day changes

## 2.2.2 (reverted)

- 5 year b'day changes

## v2.2.1

- Add a comment in Mess Menu page for hostel councils
- Reverse the order of QRpage and calendar page
- Remove inseek from drawer menu for now

## v2.2.0

- Implement Awesome Notifications
- Implement flutter_webview_pro
- Change successurl
- Update mess menu to support Android S+
- Add update prompts

## v2.1.6

- InSeek (ChatBot)

## v2.1.5

- Use new library for HTML conversion
- Add www in map url

## v2.1.4

- Open urls using external application in url launcher
- Revert back to commonhtml
- Fix mess calendar
- Auto detect links in community page
- Routing for community notifications
- Increase size of featured post if no image

## v2.1.3

- Migrate to gymkhana backend

## v2.1.2

- Corrections in urls

## v2.1.1

- Fix uni_links

## v2.1.0

- Insight Discussion Forum

## v2.0.6

- Add error checking API interceptor
- Make a QR with white background in dark mode (mess menu/take a meal)
- Remove unncessary package

## v2.0.5

- Fix image upload glitch in event form
- Add file size check in event form image upload

## v2.0.4

- Add interest in event form
- Fix event form submission api calls

## v2.0.3

- Event form
- Demo account

## v2.0.2

- Fix add to calendar not showing calendars
- Add confirm box on logout

## v2.0.1

- Search option in feed
- UI of mess menu widget

## v2.0.0

- Mess menu widget (in both iOS and Android)
- Notification bug
- Alumni login
- Achievements
- Upgrade to flutter 2

## v1.8-beta

- Added About us page in the Settings
- You can add Events to your device calendars (if you select a gmail linked calendar, it syncs across that gmail account) (Android for now)
- Fix not showing Former Roles in User Page
- Notifications now work in iOS
- Fetch the list of tags in New Complaint Page from backend rather than hard coding tags

## v1.7-beta

- Now, you can react to news post
- Decrease thumbnail size to 100px to fix jank
- Fix inconsistent markdown/html rendering all throughout the app
- Fix go to top button on iOS
- Fix All Complaints list so that it fetches the list in part

## v1.6-beta

- Complaint subscription added and comments notifications work
- Move dropdown button to FAB in Mess Menu
- Fix multiple roles (Hero animation) bug
- Add InstiApp launcher icon on Android
- Can edit/delete comments on a Complaint
- App links for Android part work
- Add back buttons on every page for iOS
- Add launcher/app icons for iOS
- Add Batch number on App Icon as Unread Notification Number on iOS
- Change map url to standalone map url for smaller js file

## v1.5-beta

- Calendar switch to heatmap of events
- Fix navDrawer selected tile
- Notifications on Android working
- Option to hide user's contact number on profile
- LoginPage made more expressive
- \[iOS\] rename bundle id to `app.insti.ios`
- Fix status bar, navigation bar colors on both OS
- SettingsPage options made more verbose
- Generated both 32/64-bit apks

## v1.4-beta

- Added notifications page and notification indicator on the NavDrawer
- Move search bars on Explore, Blog Pages to top
- Fix Gallery/Camera permission on iOS
- Made all screens notch compatible

## v1.3.1-beta

- Fix users' name containing two spaces bug
- Fix blogpage not showing loading when searching
- Add Color to statusBar and navigationBar
- Fix NewComplaint image upload with compression to not go over the limit

## v1.3-beta

- Added Hero transitions everywhere possible
- Renamed android package name to `app.insti.flutter`
- Added key signing to the android apk
- Add `FCM` to android part
- Add caching to all images and using smaller images for thumbnails
- Also caching Feed, MessMenu, Explore, Complaints, Calendar
- Redone Calendar BLoC
- Not discarding fetched posts in Blogs when search is initiated

## v1.2-beta

- Now support dark and black themes, and also you can select the colors to theme the app as well
- Implemented NewComplaintsPage (should debug image uploading though)
- Tested on an iPad, everything works fine except the creating a new complaint.

## v1.0-beta

- Implemented SettingsPage, EventEditPage, MapPage
- Event, Body pages now render markdown
- Can a specific page as the default homepage

## v0.12-alpha

- Implemented AddEventPage
- Fix Blogs: search now shows when there are no more posts to show
- Creating Events is now working

## v0.11-alpha

- Implemented ComplaintsPage, ComplaintPage
- Can upvote, comment on existing complaints

## v0.10-alpha

- Implemented CalendarPage
- Shows all events in the month overview

## v0.9-alpha

- Implemented ExplorePage
- Change back to Side Navigation Drawer
- Fix few bugs

## v0.8.1-alpha

- Implemented UserPage, NewsPage, QuickLinksPage
- Event Images zoomable now

## v0.6.0-alpha

- Implemented Body description page
- Fix bottom drawer bug in landscape

## v0.5.0-alpha

- UI changes: Move Navigation drawer and App bar to the bottom
- Add search to both Placement Blog and Internship Blog
- Add Feed page and Event description pages

## v0.4.1-alpha

- Rename instiapp to InstiApp

## v0.4-alpha

Add login persistence (Store session in shared preferences)
Swipe to refresh for Placement Blog

## v0.3.1-alpha

- Navigation drawer works for MessMenu and Placement Blog
- Placement Blog with infinite scrolling support (Thanks to this post)
- Little fixes in LoginPage
- Re-structure BLoCs
- Fix low FPS on Placement Blog

## v0.3.0-alpha

- Infinite scrolling placementBlog

  Used this for infiscrolling
  https://medium.com/flutter-community/reactive-programming-streams-bloc-6f0d2bd2d248

## v0.2-alpha

- Add auth with little use
- Add navigation drawer (just structure)

## v0.1-alpha

- Basic App with no Auth
- Mess menu
