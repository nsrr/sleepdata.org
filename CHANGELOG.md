## 0.26.0

## 0.25.1 (December 7, 2016)

### Bug Fixes
- Fixed an incorrect redirect that would occur when navigating to a URL of a
  dataset file path that had been deleted
- File checksums are now removed when dataset file references are deleted

## 0.25.0 (December 7, 2016)

### Enhancements
- **Agreement Changes**
  - Made the language for selecting multiple datasets more specific
- **Blog Changes**
  - Limit the number of blog posts shown in the sidebar
- **Gem Changes**
  - Updated to Ruby 2.3.3
  - Updated to rails 5.0.0.1
  - Updated to pg 0.19.0
  - Updated to jquery-rails 4.2.1
  - Updated to font-awesome-rails 4.7.0
  - Updated to mini_magick 4.6.0
  - Updated to sitemap_generator 5.2.0
  - Removed geocoder

### Refactoring
- Updated kaminari pagination views to use haml

### Bug Fixes
- Fixed a bug that prevented users from logging in correctly with an expired
  authenticity token
- Fixed a bug that prevented back navigation after opening a PDF
- Fixed an issue displaying images in documentation
- Fixed an issue loading Google Analytics
- Rails model errors are now again correctly styled using Bootstrap CSS classes
- Fixed a bug that prevented images from being attached to forum replies

## 0.24.2 (July 19, 2016)

### Enhancement
- **Agreement Changes**
  - Emails are now sent in background when submitting a DAUA

### Bug Fix
- Fixed emails in forked processes from not being sent

## 0.24.1 (July 11, 2016)

### Enhancements
- **Configuration Changes**
  - Updated Rails 5 configuration files

## 0.24.0 (July 6, 2016)

### Enhancements
- **Gem Changes**
  - Updated to rails 5.0.0
  - Updated to devise 4.2.0
  - Updated to turbolinks 5
  - Updated to coffee-rails 4.2
  - Updated to jbuilder 2.5
  - Updated to simplecov 0.12.0
  - Updated to carrierwave 0.11.2

### Bug Fix
- Added missing typeahead.js library

### Refactoring
- Removed unused database tables `broadcast_comments` and
  `broadcast_comment_users`
- Prefer use of `after_create_commit :fn` instead of
  `after_commit :fn, on: :create`

## 0.23.0 (June 24, 2016)

### Enhancements
- **Admin Changes**
  - Added admin view for blog post and forum topic replies
  - Improved speed of dataset audits page
- **Blog Changes**
  - Added view_count column to track blog post views
  - Improved the blog index to show extracts of the blog posts
- **Forum Changes**
  - Forum topics now track views and have better URL structure
  - Users can upvote, downvote, and reply directly to other forum posts
  - Users now receive in-app notifications when a new reply is added to a forum
    topic to which they are subscribed
- **General Changes**
  - Added a sitemap for better indexing on Google and Bing
- **Search Added**
  - A site-wide search has been added that searches through blog posts and forum
    topics
- **Gem Changes**
  - Added the pg_search gem for full-text search
  - Removed dependency on jquery-ui-rails

### Refactoring
- Removed deprecated columns from agreement_events
- Removed deprecated column from variables
- Removed unused controllers and associated views
- Reorganized JavaScript files

## 0.22.0 (June 13, 2016)

### Enhancements
- **Admin Changes**
  - Updated the graph tick interval to be 512MB instead of 500MB
  - Simplified filters on DAUA review index
- **Gem Changes**
  - Updated to kaminari 0.17.0
  - Updated to devise 4.1.1
  - Removed dependency on contour

### Refactoring
- Removed dependency on database serialize for simpler migration to Rails 5

## 0.21.0 (June 9, 2016)

### Enhancements
- **Admin Changes**
  - The y-axis in Downloads by Month admin report now more accurately displays
    sizes over 1TB
- **General Changes**
  - Added Data Sharing Language for use in grant submissions

### Bug Fix
- Fixed an issue that prevented users from requesting datasets due to the
  submission status from being incorrectly set

## 0.20.0 (May 9, 2016)

### Enhancements
- **General Changes**
  - Improved meta tags for sharing a link to the NSRR on Facebook and Google+
- **Agreement Changes**
  - Emails sent to reviewers for resubmitted agreements now indicate that the
    agreement is a resubmission
- **Blog Changes**
  - Admins can now create blog categories
  - Blogs can now be assigned a category
  - Blog posts have a discussion section that is sorted by best or new comments
  - Comments on blog posts can be up- and down-voted
  - Comments can be ordered by highest ranked or newest
- **Gem Changes**
  - Updated to Ruby 2.3.1
  - Added font-awesome-rails

### Bug Fix
- Agreement report tables now correctly shows counts of submissions that have
  been started

### Refactoring
- Removed deprecated code from domain model

## 0.19.2 (April 18, 2016)

### Enhancement
- **Dataset Changes**
  - Reduced the polling speed page refresh while indexing files

### Bug Fix
- Fixed a bug that prevented domain options without missing key from being saved

## 0.19.1 (April 18, 2016)

### Enhancements
- **Gem Changes**
  - Updated to carrierwave 0.11.0
  - Updated to mini_magick 4.5.1

### Bug Fix
- Fixed a bug that prevented the documentation from being synced

## 0.19.0 (April 14, 2016)

### Enhancements
- **Agreement Changes**
  - Principal reviewers can now close agreements
  - Review process now quickly displays past datasets approved for data user
  - IRB approval attachment is now more prominently displayed for reviewers
- **Blog Changes**
  - Community members can now more easily edit blogs
  - Keywords can be added to blog posts to increase visibility on search engines
- **Dataset Changes**
  - Improved browsing file downloads on smaller devices
  - File download commands can now be easily copied to clipboard
  - Dataset file folders can now have individual descriptions
  - Dataset tracking of file information, like MD5 and file size, has been
    improved
  - Requesting a single file through the JSON API now works as well
    - This allows the nsrr gem to download single files
  - Dataset editors can now view and filter agreements for single datasets
  - The dataset files directory is now created on dataset creation
- **Dashboard Changes**
  - Improved display of admin pages linked from the dashboard
- **Forum Changes**
  - Changing subscription preference on forum topics no longer reloads the
    entire page
- **Map Changes**
  - Map location is now pulled using a local database lookup
- **Mobile Changes**
  - Added a link to the user dashboard in mobile navigation menu
- **Email Changes**
  - Removed margins in emails to display better across email clients
- **Variable Changes**
  - Variable labels are now added as meta page keywords to increase visibility
    on search engines
  - Variable forms now display a message if the file is available only viewable
    with a data access and use agreement
  - Variable forms now display a message if the linked file is not found on the
    server
  - Improved how variable domain options are stored
  - Fixed the ordering when transitioning between variables using arrow keys
- **API Changes**
  - Introduced a new API for dataset file downloads that supports both full
    folder and individual file downloads
    - `GET /api/v1/datasets.json`
      - List all viewable datasets
    - `GET /api/v1/datasets/:dataset.json`
      - Displays information on a dataset
    - `GET /api/v1/datasets/:dataset/files.json`
      - Displays a list of files available at the dataset files root directory
    - `GET /api/v1/datasets/:dataset/files.json?path=folder`
      - Displays a list of files available in the dataset `folder` directory
    - `GET /api/v1/datasets/:dataset/files.json?path=folder/file.txt`
      - Returns an array containing information about `folder/file.txt`
  - All of the above commands can also optionally include the `auth_token`
    parameter to authenticate a specific user to view information on private
    datasets and files
  - Added a new API for authenticating account
    - `GET /api/v1/account/profile.json`
      - Returns profile information for authenticated account
- **Gem Changes**
  - Updated to rails 4.2.6
  - Restricted mini_magick to 4.4.0
  - Added maxminddb gem

### Bug Fix
- Fixed documentation links on dataset and tool sync page

### Refactoring
- Started cleanup and refactoring, and additional testing of controllers

## 0.18.4 (March 2, 2016)

### Enhancements
- **General Changes**
  - Added a Past Contributor page
- **Agreement Changes**
  - Reviewers comments and votes on DAUAs now update inline using AJAX
- **Email Changes**
  - Improved the responsiveness and display of emails on smaller devices
- **Gem Changes**
  - Updated to rails 4.2.5.2
  - Updated to geocoder 1.3.1
  - Updated to simplecov 0.11.2

### Bug Fixes
- Fixed a bug that occurred when updating variables without uploading datasets
- Fixed an issue that caused the blog RSS from being cached for friendly
  forwarding
- Fixed a bug that inserted placeholder text into textarea elements when using
  Internet Explorer in combination with Turbolinks
- Fixed an issue where long URLs would break topic views on mobile

## 0.18.3  (January 26, 2016)

### Enhancements
- **Gem Changes**
  - Updated to rails 4.2.5.1
  - Updated to jquery-rails 4.1.0

## 0.18.2 (January 21, 2016)

### Enhancements
- **Agreement Changes**
  - Emails are now sent in background when a principal reviewer approves an
    agreement or asks for an agreement resubmission
  - Improved user interface for the DAUA review process
- **Submission Changes**
  - Improved visibility of "Get Started" button when launching a new DAUA
- **Registration Changes**
  - A welcome email is now generated for new users filling out:
    - dataset access use agreements
    - dataset hosting requests
    - and tool contributions
- **Blog Changes**
  - Added an ATOM feed to allow new blogs posts to be picked up by RSS feed
    readers

## 0.18.1 (January 20, 2016)

### Enhancements
- **Forum Changes**
  - Fixed a minor UI issue with the forum post edit and delete buttons
- **Agreement Changes**
  - Datasets are now ordered properly while reviewing existing DAUAs
- **Contact Changes**
  - Minor update to text on contact page

### Bug Fix
- Fixed an issue approving and setting tags on DAUAs

## 0.18.0 (January 20, 2016)

### Enhancements
- **General Changes**
  - Improved the user interface across the site for easier navigation and a
    cleaner look
  - Started work on a comprehensive Site Map
  - Emails sent from site have been updated to match the new user interface
- **Dataset Changes**
  - Improved dataset access request flow
  - Added call to action for researchers who wish to contribute datasets to the
    NSRR
  - Users can now fill out a dataset hosting request form to host new datasets
    on the NSRR
  - Datasets now track all versions and maintain data dictionary changes and
    history
- **Tool Changes**
  - Users can now submit URLs for tools to be listed on the NSRR
  - GitHub repositories with READMEs and GitHub gists can now be contributed as
    tools
  - Tool descriptions are pulled automatically and can be written and previewed
    using markdown
- **Variable Changes**
  - Added a table of domain options for variables that are linked to domains
  - Variables are now sorted by relevance when searching for key terms
  - Individual variable pages have been redesigned and include additional
    information about known issues and variable history
  - Folder navigation has been simplified on the variable index
  - Embedded PDFs for variables are now displayed directly on the variable page
- **Dashboard Added**
  - Users can now view their personal dashboard that contains updates and links
    to their datasets and other NSRR related activity
- **Blog Added**
  - Community managers can now create new blogs posts that are viewable on the
    NSRR home page
  - Images can be easily added via drag-and-drop while editing blog posts
  - Blogs can be previewed while editing
- **Forum Changes**
  - Images can now be more easily added to forum posts
- **Gem Changes**
  - Updated to Ruby 2.3.0
  - Updated to rails 4.2.5
  - Updated to pg 0.18.4
  - Updated to simplecov 0.11.1
  - Updated to web-console 3.0

### Bug Fix
- Fixed an issue where chart numbers would not show well on charts with dark
  columns
- Fixed various navigation issues in IE caused by caching

## 0.17.3 (November 6, 2015)

### Enhancements
- **Challenge Updates**
  - A new challenge has been added!
    - Flow Limitation - Part 2 is now available for users to fill out
    - The original Flow Limitation challenge has been archived
- **General Changes**
  - Fixed a minor display issue when proofing a DAUA submission in Step 1
  - Updated items on the carousel
  - Added call to action on research showcase pages
  - Updated link to the NSRR Cross Dataset Query Interface
  - Removed swiping left and right on variable pages from mobile view
  - Updated styling on dataset and tool image pages
- **Forum Changes**
  - Large images are now scaled down to fit correctly in forum posts
- **Admin Changes**
  - Improved loading time of overall file download statistics
  - Improved loading time of overall file downloads per month graph
- **Gem Changes**
  - Removed minitest-reporters
  - Updated to pg 0.18.3

### Bug Fix
- Fixed a bug that prevented users with tokens ending in hyphens from
  authenticating correctly while using the NSRR gem

## 0.17.2 (August 25, 2015)

### Enhancements
- **General Changes**
  - Updated styling on documentation sync pages
- **Admin Changes**
  - Agreement reports are now filtered by regular members
- **Gem Changes**
  - Use of Ruby 2.2.3 is now recommended
  - Updated to rails 4.2.4
  - Added web-console

## 0.17.1 (July 8, 2015)

### Enhancements
- **Gem Changes**
  - Updated to contour 3.0.1

## 0.17.0 (June 30, 2015)

### Enhancements
- **General Changes**
  - Added Google Analytics
  - Fixed some minor spacing issues on forum
  - User setting page now lists all active dataset requests for a user
- **Showcase Added**
  - Added a page highlighting Matt Butler's work on Novel Sleep Measures and
    Cardiovascular Risk
  - Highlighted Shaun Purcell's work on the home page carousel
- **Forum Changes**
  - Removed auto-subscribing users to new forum topics
  - Comments on topics are now immediately sent to anyone subscribed to the
    topic
  - Daily forum digests have been removed
  - Forum index font size has been reduced to display more topics
- **Agreement Changes**
  - The DAUA process has been simplified to 6 steps total
  - The agreements administration is being merged into the reviewer page
    - This will help consolidate the DAUA approval process in a single place for
      principal reviewers
  - Users not authorized to sign a DAUA are now provided a link that they can
    send to the authorized user
  - An email is sent to the DAUA user when the authorized user has signed the
    DAUA
  - Appending multiple users to an organization's DAUA has been removed
  - The Duly Authorized Representative can now review the entire agreement
    before signing
  - Agreement changes are now audited so that reviewers can view changes more
    easily between resubmissions
  - Principal reviewers can now modify the requested datasets during the review
    process
  - Principal reviewers can now export information on all agreements as a CSV
  - Clarified reference to the IRB Assistance page
  - Improved the user interface for the DAUA submission process
- **Challenge Changes**
  - Added an export for the Flow Limitation challenge
- **Dataset Changes**
  - The dataset pages have been updated to be easier to navigate
  - Dataset variable and file pages now have a newer interface
  - Visiting a dataset page now better displays a current users process of
    accessing data
  - Simplified specifying user roles for dataset editors
- **Tool Changes**
  - Tool editors can now sync documentation repositories
- **Administrative Changes**
  - Admin location report now better shows unmatched locations
  - The admin dashboard now points to the consolidated reviews path
  - The admin now has a report view that shows user roles across datasets
  - Admins can now see a list of agreements on individual user pages
- **Gem Changes**
  - Use of Ruby 2.2.2 is now recommended
  - Updated to rails 4.2.3
  - Updated to pg 0.18.2
  - Updated to simplecov 0.10.0
  - Updated to chunky_png 1.3.4
  - Updated to contour 3.0.0
  - Added differ 0.1.2 gem to see changes in DAUAs
  - Updated to kaminari 0.16.3
  - Updated to redcarpet 3.3.2
  - Updated to geocoder 1.2.9
  - Updated to figaro 1.1.1

### Bug Fix
- Fixed a bug that prevented reviewers seeing DAUA signature if the user signed
  and checked that they were unauthorized to sign the DAUA
- Fixed an issue where users could post images and links on forum without having
  explicit permission to post links or images
- IRB Assistance Template should now show up properly for regular users
- Fixed map not picking up certain cases of users living in the US
- Fixed an issue on iOS 7 devices that were incorrectly rendering `vh` units
- Fixed a bug rendering previews for new and existing comments
- Posts on forum now correctly display when a user uses the `<` symbol

## 0.16.1 (April 1, 2015)

### Bug Fix
- Fixed incorrectly labeled Signal 13 on the Flow Limitation Challenge

## 0.16.0 (March 23, 2015)

### Enhancements
- **General Changes**
  - Fixed a minor styling issue with pagination on dataset variable indexes
  - Topic tags are now faded using grayscale instead of opacity to maintain
    contrast between text and tag color
  - Streamlined login system by removing alternate logins
  - Updated the design of the NSRR footer
  - Started work on some parallax-enabled pages for future UI updates
  - Redesigned the interface for the NSRR home page
  - Added a new Contact Us page
  - Updated the user sign in and registration page
  - Removed wget documentation in favor of the NSRR Downloader Ruby Gem
  - Added a map page to show NSRR membership
  - The menu has minor UI improvements to scale better across different device
    sizes
- **Showcase Added**
  - A new showcase section has been added that highlights certain areas of
    interest for researchers
  - Added a page highlighting Shaun Purcell's work on Genetics of Sleep Spindles
  - Added a page that covers the purpose of the NSRR in 5 steps
  - Added a new showcase carousel on the home page aimed at highlighting
    showcase items
  - A new page to showcase new tools and datasets on the NSRR website
  - A new demo page is now available that is aimed at getting new users
    started by:
    - downloading data
    - opening CSV datasets and accessing variable information
    - extracting information from EDFs
- **Challenges Added**
  - The flow limitation challenge is now available
- **Forum Changes**
  - The forum user interface has been updated
  - Forum post anchors now correctly offset based on the top navigation bar
  - Users can now post twice in a row on a forum topic
  - Forum markdown has been improved and examples are provided under the Markup
    tab
    - Blockquotes: `> This is quote`
    - Highlight: `==This is highlighted==`
    - Underline: `_This is underlined_`
    - Superscript: `This is the 2^(nd) time`
    - Strikethrough: `This is ~~removed~~`
- **Dataset Changes**
  - Datasets now highlight the ability to:
    - download the full dataset using the NSRR gem
    - browse all covariates online
  - Dataset documentation pages now scale better with screen resolution to make
    text more legible
  - Dataset owners can now highlight key information about their dataset
  - Improved the dataset API to allow the NSRR gem to download data from private
    datasets for authorized users
- **Tool Changes**
  - Titles no longer overlap tools tags on the tools index
- **Agreement Changes**
  - Step 2 now has additional instructions to clarify the importance of
    describing the "Specific Purpose", and selecting an appropriate number of
    datasets
  - The signature step now allows users to opt out of signing the agreement if
    they have institutional requirements forbidding signing of agreements
  - Users opting for NSRR Committee review now need to attest that they have
    received Human Subjects Protections Training
  - Academic agreements no longer include Indemnification Clause (11 and 12),
    and have been renumbered
- **Email Changes**
  - The password reset email and other emails have had their template updated
- **Administrative Changes**
  - Admins can now set the auto-subscribe forum notifications features for users
  - Location statistics now load more quickly
- **Gem Changes**
  - Updated to rails 4.2.1
  - Updated to pg 0.18.1
  - Updated to contour 3.0.0.beta1
  - Updated to kaminari 0.16.2
  - Updated to jquery-rails 4.0.3
  - Use Haml for new views
  - Use Figaro to centralize application configuration
- Use of Ruby 2.2.1 is now recommended

### Bug Fix
- Fixed a bug that caused too much information to be logged to the log file
- Fixed an issue where friendly redirect on sign out was not redirecting to the
  last page the user was on
- Dataset editors can now properly view private datasets on which they are an
  editor

## 0.15.3 (January 6, 2015)

### Bug Fix
- Fixed a bug that would occasionally occur when resetting a dataset folder
  index on reading an uninitialized folder index

## 0.15.2 (January 6, 2015)

### Enhancements
- **General Changes**
  - Added timestamps to comments
- **Administrative Changes**
  - Reviews can now be ordered by the agreement number

### Bug Fix
- Fixed a bug that prevented a dataset's root file index from being generated

### Refactoring
- Use `.scss` instead of `.css.scss` to stay consistent with Rails
  recommendations

## 0.15.1 (December 30, 2014)

### Enhancements
- Use of Ruby 2.2.0 is now recommended
- **Gem Changes**
  - Updated to rails 4.2.0
  - Updated to contour 2.6.0.rc

## 0.15.0 (December 11, 2014)

### Enhancements
- **General Changes**
  - Enabled turbolinks progress bar on page changes
  - Email notifications now provide a link to the user settings page to allow
    users to update their email preferences
  - Removed UserVoice, users tend to contact the NSRR via the support email
    address and the forum
- **Dataset Changes**
  - Dataset owners and editors can now add users as `editors`, `reviewers`, and
    `viewers`
  - Reviewers can now make comments, approve, and reject DAUAs that request
    access to the dataset the reviewer is on
  - Dataset editors can now sync documentation repositories
- **Agreement Changes**
  - New review process for agreements
    - Reviewers can comment and approve or reject agreements
    - Reviewers are specified per dataset and can only review agreements for
      their dataset
  - Reviewers are sent weekly digests of agreements they have not yet reviewed
  - Reviewers are now notified in place of system admins when a DAUA is
    submitted
  - Reviewers now receive a notification email when another reviewer mentions
    them on an agreement
  - Agreements can now be annotated using specific tags
- **Administrative Changes**
  - Administrators can now see a breakdown of agreements by status and by tag
  - Improved speed at which stats page is displayed for administrators
- Updated Google Omniauth to no longer write to disk
- Use of Ruby 2.1.5 is now recommended
- **Gem Changes**
  - Updated to rails 4.2.0.rc2

## 0.14.2 (November 10, 2014)

### Bug Fixes
- Fixed styling of individual users' download statistics
- Fixed hover effect information on yearly download chart

## 0.14.1 (November 4, 2014)

### Enhancements
- **Administrative Changes**
  - Agreements are now filterable by status
  - Agreements are now numbered to help identify them more quickly
  - Download statistics now available on user pages
  - Yearly download chart added to visually see downloads by month, dataset, and
    user type
- **Dataset Changes**
  - Download audits and page view reports are now indexed to load more quickly

### Bug Fix
- Dataset background tasks are now launched using the proper environment

## 0.14.0 (November 3, 2014)

### Enhancements
- **Agreement Changes**
  - Step 8, Intended Use of Data, now requests more specific information to help
    the NSRR Review Committee
- **Dataset Changes**
  - New dataset releases can now be deployed using the Spout data dictionary
    management gem
    - Spout, https://github.com/sleepepi/spout, tests and manages data
      dictionaries and datasets
- **Gem Changes**
  - Updated to rails 4.2.0.beta4
  - Updated to contour 2.6.0.beta8
  - Updated to coffee-rails 4.1.0
  - Updated to redcarpet 3.2.0
  - Updated to simplecov 0.9.1
- Use of Ruby 2.1.4 is now recommended

## 0.13.0 (October 14, 2014)

### Enhancements
- **Administrative Changes**
  - Last submitted at column added to allow better sorting on the administrator
    agreement view
  - Minor layout improvements for reviewing submitted agreements
- **Agreement Changes**
  - PDFs of submitted and approved agreements can now be downloaded and printed
- **Dataset Changes**
  - EDFs can now be previewed in the Altamira online EDF browser
- **Forum Changes**
  - Users can now mention other users by username in forum posts
    - Ex: "Please look at this topic @remomueller."
  - Users can set their forum username under their settings
  - Users get notified by email when they are mentioned in a comment
  - Users can turn off receiving mention emails in their settings
  - Typing '@' will allow users to autocomplete usernames while creating new
    topics and posts
  - Core and AUG members can now add tags to topics
- **Gem Changes**
  - Updated to contour 2.6.0.beta7

### Bug Fixes
- Fixed an issue that caused topics to render markdown comments incorrectly

## 0.12.0 (October 1, 2014)

### Enhancements
- **Administrative Changes**
  - Added an administrative dashboard and a link in the dropdown menu for system
    admins
- **Dataset Changes**
  - Dataset file access is now controlled by the new DAUA process
  - Dataset editors can now refresh download folders through the web interface
- **Gem Changes**
  - Updated to rails 4.2.0.beta2

## 0.11.2 (September 26, 2014)

### Bug Fix
- Fixed a bug that prevented emails from being delivered if the logo file was
  unavailable

## 0.11.1 (September 24, 2014)

### Bug Fix
- Fixed a bug that prevented non-admin users from starting a new DAUA submission
  process

## 0.11.0 (September 23, 2014)

### Enhancements
- **General Changes**
  - Added a new online DAUA application process
    - DAUA can be filled out by an individual or an organization
    - Multiple submissions can be created for different datasets
    - Completed submissions can be printed
    - In progress submissions can be deleted
    - Expired submissions can be renewed
- **Forum Changes**
  - Users are now subscribed to new posts by default
    - Users can opt out of this setting under their user settings.
- Use of Ruby 2.1.3 is now recommended

## 0.10.0 (September 8, 2014)

### Enhancements
- **General Changes**
  - The official NSRR ruby gem is now supported, https://rubygems.org/gems/nsrr
    - More information here: https://github.com/nsrr/nsrr-gem
  - The wget download option has been hidden in favor of the NSRR gem command
    - Add `?wget=1` to the download url bar to see the `wget` download command
      syntax
  - Added UserVoice integration to collect better feedback on the NSRR website
  - Restructured the menu bar to provide more space for page content
- **Dataset Changes**
  - Download folders now provide customizable commands using the NSRR gem
- **Variable Changes**
  - Commonly used variables can now be filtered on the variables index
  - Older variable graphs can now be viewed by passing the older version on the
    show page
    - Ex: https://sleepdata.org/datasets/shhs/variables/rdi3p?v=0.2.0
  - Variables index and show page styling updated to be more consistent with the
    rest of the NSRR website
- **Forum Changes**
  - The forum is now linked in the main menu
- **Gem Changes**
  - Updated to rails 4.2.0.beta1
  - Updated to contour 2.6.0.beta6
  - Updated to simplecov 0.9.0

### Bug Fix
- Fixed a bug authenticating some users via their token

## 0.9.6 (July 14, 2014)

### Enhancements
- **Dataset Changes**
  - Increased the number of datasets to 18 to allow all scheduled datasets to be
    shown on a single page
  - Dataset navigation only shows the variables tab if the dataset has variables
- **Variable Changes**
  - The index page can now be viewed as a list or a grid
- **Gem Changes**
  - Updated to kaminari 0.16.1

### Bug Fix
- Fixed a bug that prevented certain dataset variables from including navigation
  to neighboring variables

## 0.9.5 (July 9, 2014)

### Enhancements
- **Dataset Changes**
  - Highlighted files are now downloaded automatically when a user navigates to
    the downloads section
- **Gem Changes**
  - Removed dependency on ruby-ntlm gem

## 0.9.4 (July 9, 2014)

### Bug Fix
- Fixed an issue that prevented certain file indexes from being generated
  properly

## 0.9.3 (July 8, 2014)

### Enhancements
- **Dataset Changes**
  - Files can be individually marked as publicly available
- **Gem Changes**
  - Updated to rails 4.1.4

## 0.9.2 (June 27, 2014)

### Enhancements
- **Variable Changes**
  - Histograms for graphs now include units on the x-axis where appropriate
- **Gem Changes**
  - Updated to rails 4.1.2

## 0.9.1 (June 25, 2014)

### Enhancements
- **General Changes**
  - Added grant number to the About page
- **Forum Changes**
  - Forum uses identicons for users who do not have a gravatar set
- **Variable Changes**
  - Dataset variables index now displays 100 variables per page, up from 50

## 0.9.0 (June 20, 2014)

### Enhancements

- **Forum Added**
  - Added the ability for registered users to create topics on the forum and to
    post comments on other topics
  - Core and AUG members are now highlighted as such on their forum posts
  - Comments can be previewed before being posted to the forum topic
  - System admins can lock, pin, and delete topics
  - System admins can ban users from posting on the forum
  - Users who have commented on now receive daily forum updates to topics where
    they are subscribed
  - Users may not post consecutive comments on the forum
    - This is currently enabled to discourage topic "bumping", multi-comment
      spam, and to encourage clear dialogue between users
- **Variable Changes**
  - Swiping left or right now navigates to next or previous variable on mobile
    devices
- **Administrative Changes**
  - Syncing dataset and tool documentation is now more robust

### Bug Fix
- Fixed an issue where navigating to dataset downloads for a dataset with no
  files could cause a redirect loop

## 0.8.1 (May 28, 2014)

### Enhancement
- **General Changes**
  - Changed the file organization of variable images and graphs
    - The new file structure now includes the data dictionary version of the
      variable

## 0.8.0 (May 22, 2014)

### Enhancements
- **Dataset Changes**
  - The variable index has been changed for better variable navigation
  - Added the ability to view variables on their own unique pages
  - Each variable now includes interactive charts
- **Gem Changes**
  - Updated to contour 2.5.0
  - Updated to geocoder 1.2.1
- Use of Ruby 2.1.2 is now recommended

## 0.7.3 (May 8, 2014)

### Enhancements
- **Gem Changes**
  - Updated to rails 4.1.1

## 0.7.2 (April 15, 2014)

- **Administrative Changes**
  - Added tables of regular member registrations by country and state for
    reporting purposes

## 0.7.1 (April 14, 2014)

### Enhancements
- **Administrative Changes**
  - Large numbers on statistics page now include commas
- **Dataset Changes**
  - Windows wget commands now include `--no-check-certificate`
- **General Changes**
  - `mailto` links in email now use the same color as `href` links

## 0.7.0 (April 9, 2014)

### Enhancements
- **Administrative Changes**
  - Site admins are notified by email when an admin approves or asks a user to
    resubmit a DAUA
  - Added stats overview for system admins to track signups, DAUA submissions,
    and file downloads
- **Dataset Changes**
  - Dataset owners are notified when users make new dataset file access requests
  - Variable popups are now hidden when the `Esc` key is pressed
  - Users are notified by email when a dataset editor approves their file access
    request
- **General Changes**
  - Updated email styling template
  - Minor wording changes on About page and Home page
  - Documentation pages for tools and datasets now include the filename as part
    of the title
- **Gem Changes**
  - Updated to rails 4.1.0
  - Updated to contour 2.5.0.beta1
  - Removed turn, and replaced with minitest and minitest-reporters

## 0.6.2 (April 2, 2014)

### Enhancements
- Added updated Data Access and Use Agreement PDF

## 0.6.1 (April 1, 2014)

### Bug Fix
- Fixed a typo on about page

## 0.6.0 (March 31, 2014)

### Enhancements
- **Dataset Changes**
  - Dataset editors can now approve user access to datasets based on DAUA
    criteria
  - Removed variable lists to clean up interface
    - Variables are now downloaded via the dataset CSV download from the files
      area
  - Datasets can now specify release dates to allow users to see when those
    datasets will have files available
    - Datasets are highlighted when they have data available for download
  - Dataset file downloads display steps the user needs to take to access the
    file download
- **Tool Changes**
  - Tools can be marked as private to allow editors to work on them while they
    are a work in progress
- **Gem Changes**
  - Updated to rails 4.0.4
  - Updated to carrierwave 0.10.0
  - Updated to redcarpet 3.1.1
  - Updated to turn 0.9.7

## 0.5.0 (March 17, 2014)

### Enhancements
- **Administrative Changes**
  - New sign ups can now be reviewed by system administrators
  - DAUA review process put into place for system administrators
    - Emails are sent to system administrators when DAUAs are submitted
    - Users are notified when their DAUAs are approved or sent back for
      resubmission
    - Executed DAUAs can now be uploaded alongside the originally submitted
      DAUAs
  - Added Academic User Group page and added research summary for AUG Members
  - Documentation for repositories can now be synced by system administrators
- **Dataset Changes**
  - Datasets now display a list of the contributors
  - Variables now reference the forms on which they were collected
- **Tool Changes**
  - Tools now display a list of the contributors
- **Gem Changes**
  - Updated to contour 2.4.0
- Use of Ruby 2.1.1 is now recommended

## 0.4.0 (February 20, 2014)

### Enhancements
- Signing in and signing out on the datasets files page now forwards back to the
  last folder location
  - This was disabled in previous versions so that file downloads wouldn't
    trigger after sign in or sign out
- Datasets header tabs now display `Variables` instead of `Collection` and
  `Search` has been removed
- `Variables` section, formerly the `Collection` now displays a note on why
  certain variables have gold borders
- Added more descriptive links for datasets and tools
- Reduced the size of the header bar on smaller screen sizes
- External links now have different styling from internal links
- Markdown no longer escapes numbers to their ASCII representation re-enabling
  ordered lists in Markdown
- Documentation code fences can now be prettified using `<!--?prettify?-->`
  immediately before the code fence
- **Tool Changes**
  - Tools can now specify one of the following tool types:
    - Matlab
    - R Language
    - Utility
    - Java
    - Web
  - Authors can now be specified for tools
- **Gem Changes**
  - Updated to rails 4.0.3
  - Updated to kaminari 0.15.1
  - Updated to contour 2.4.0.beta3

### Bug Fix
- Fixed a bug preventing dataset owners from viewing dataset access requests
- Fixed `add` button floating lower than intended in some browsers

## 0.3.0 (January 17, 2014)

### Enhancements
- Home page is now more dynamic and includes direct links to available
  documentation, data, and tools
- Covariate datasets can now be requested and downloaded if the user has been
  granted access to the dataset
- Added prototype of data use agreement request process
- **Tool Changes**
  - Tools can now have multiple pages of documentation identical to datasets
  - Tool specific paths can now be referenced:
    - `:pages_path:` => `/tools/SLUG/pages`
    - `:images_path:` => `/tools/SLUG/images`

## 0.2.0 (January 13, 2014)

### Enhancements
- Use of Ruby 2.1.0 is now recommended
- **Gem Changes**
  - Updated to pg 0.17.1
  - Updated to jbuilder 2.0
  - Updated to contour 2.2.1

## 0.1.0 (December 20, 2013)

### Enhancements

- **Dataset Changes**
  - Datasets can be added and shared publicly or privately
  - **Documentation**
    - Dataset editors can create, edit, and update documentation pages
    - Datasets can be documented using markdown or plain text across multiple
      pages
      - `:datasets_path:` and `:tools_path:` can now be referenced in
        documentation
    - Dataset specific paths can now be referenced:
      - `:pages_path:` => `/datasets/SLUG/pages`
      - `:images_path:` => `/datasets/SLUG/images`
      - `:files_path:` => `/datasets/SLUG/files`
    - Dataset documentation is now searchable
    - Dataset documentation page views are now audited
    - Documentation pages can now embed images from the dataset images folder
      - Images can be viewed inline
  - **File Downloads**
    - File downloads are now audited and can be reviewed by dataset creators
    - Users can now request access to file downloads for datasets
    - Dataset editors can approve/deny user file access requests
    - Dataset files are indexed to improve viewing folders with 1,000 or more
      files
  - **Collection**
    - Users can search across multiple datasets that have an associated data
      dictionary
      - [Spout](https://github.com/sleepepi/spout) helps format and maintain
        JSON data dictionaries
      - An example data dictionary is the
        [We Care Data Dictionary](https://github.com/sleepepi/wecare-data-dictionary)
      - Variables with pre-computed charts now display the chart in the
        collection viewer
      - Users can create lists of variables on the collection viewer
      - Variable charts are loaded when the image is placed in the web browser
        viewport
- **Tool Changes**
  - Tools can be added and documented

## 0.0.0 (October 21, 2013)

- Initial prototype of the National Sleep Research Resource splash page
- Skeleton files to initialize Rails application with testing framework and
  continuous integration
- Added the We Care Dataset to prototype bulk file downloads
- Added Windows and Mac OS X/Linux instructions for installing GNU Wget
