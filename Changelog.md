# Changelog

## Unreleased

* Nothing here yet

## v1.3.1-beta

* Fix users' name containing two spaces bug

## v1.3-beta
 
* Added Hero transitions everywhere possible
* Renamed android package name to `app.insti.flutter`
* Added key signing to the android apk
* Add `FCM` to android part
* Add caching to all images and using smaller images for thumbnails
* Also caching Feed, MessMenu, Explore, Complaints, Calendar
* Redone Calendar BLoC
* Not discarding fetched posts in Blogs when search is initiated

## v1.2-beta

* Now support dark and black themes, and also you can select the colors to theme the app as well
* Implemented NewComplaintsPage (should debug image uploading though)
* Tested on an iPad, everything works fine except the creating a new complaint. 

## v1.0-beta

* Implemented SettingsPage, EventEditPage, MapPage
* Event, Body pages now render markdown 
* Can a specific page as the default homepage

## v0.12-alpha

* Implemented AddEventPage
* Fix Blogs: search now shows when there are no more posts to show 
* Creating Events is now working

## v0.11-alpha

* Implemented ComplaintsPage, ComplaintPage
* Can upvote, comment on existing complaints

## v0.10-alpha

* Implemented CalendarPage
* Shows all events in the month overview 

## v0.9-alpha

* Implemented ExplorePage
* Change back to Side Navigation Drawer
* Fix few bugs

## v0.8.1-alpha

* Implemented UserPage, NewsPage, QuickLinksPage
* Event Images zoomable now

## v0.6.0-alpha

* Implemented Body description page
* Fix bottom drawer bug in landscape

## v0.5.0-alpha

* UI changes: Move Navigation drawer and App bar to the bottom
* Add search to both Placement Blog and Internship Blog
* Add Feed page and Event description pages

## v0.4.1-alpha

* Rename instiapp to InstiApp

## v0.4-alpha

Add login persistence (Store session in shared preferences)
Swipe to refresh for Placement Blog

## v0.3.1-alpha

* Navigation drawer works for MessMenu and Placement Blog
* Placement Blog with infinite scrolling support (Thanks to this post)
* Little fixes in LoginPage
* Re-structure BLoCs
* Fix low FPS on Placement Blog

## v0.3.0-alpha

* Infinite scrolling placementBlog

    Used this for infiscrolling
    https://medium.com/flutter-community/reactive-programming-streams-bloc-6f0d2bd2d248

## v0.2-alpha

* Add auth with little use
* Add navigation drawer (just structure)

## v0.1-alpha

* Basic App with no Auth
* Mess menu