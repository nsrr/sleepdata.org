## 0.13.0

## 0.12.0 (October 1, 2014)

### Enhancements
- **Administrative Changes**
  - Added an administrative dashboard and a link in the dropdown menu for system admins
- **Dataset Changes**
  - Dataset file access is now controlled by the new DAUA process
  - Dataset editors can now refresh download folders through the web interface
- **Gem Changes**
  - Updated to rails 4.2.0.beta2

## 0.11.2 (September 26, 2014)

### Bug Fix
- Fixed a bug that prevented emails from being delivered if the logo file was unavailable

## 0.11.1 (September 24, 2014)

### Bug Fix
- Fixed a bug that prevented non-admin users from starting a new DAUA submission process

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
    - Add `?wget=1` to the download url bar to see the `wget` download command syntax
  - Added UserVoice integration to collect better feedback on the NSRR website
  - Restructured the menu bar to provide more space for page content
- **Dataset Changes**
  - Download folders now provide customizable commands using the NSRR gem
- **Variable Changes**
  - Commonly used variables can now be filtered on the variables index
  - Older variable graphs can now be viewed by passing the older version on the show page
    - Ex: https://sleepdata.org/datasets/shhs/variables/rdi3p?v=0.2.0
  - Variables index and show page styling updated to be more consistent with the rest of the NSRR website
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
  - Increased the number of datasets to 18 to allow all scheduled datasets to be shown on a single page
  - Dataset navigation only shows the variables tab if the dataset has variables
- **Variable Changes**
  - The index page can now be viewed as a list or a grid
- **Gem Changes**
  - Updated to kaminari 0.16.1

### Bug Fix
- Fixed a bug that prevented certain dataset variables from including navigation to neighboring variables

## 0.9.5 (July 9, 2014)

### Enhancements
- **Dataset Changes**
  - Highlighted files are now downloaded automatically when a user navigates to the downloads section
- **Gem Changes**
  - Removed dependency on ruby-ntlm gem

## 0.9.4 (July 9, 2014)

### Bug Fix
- Fixed an issue that prevented certain file indexes from being generated properly

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
  - Added the ability for registered users to create topics on the forum and to post comments on other topics
  - Core and AUG members are now highlighted as such on their forum posts
  - Comments can be previewed before being posted to the forum topic
  - System admins can lock, pin, and delete topics
  - System admins can ban users from posting on the forum
  - Users who have commented on now receive daily forum updates to topics where they are subscribed
  - Users may not post consecutive comments on the forum
    - This is currently enabled to discourage topic "bumping", multi-comment spam, and to encourage clear dialogue between users
- **Variable Changes**
  - Swiping left or right now navigates to next or previous variable on mobile devices
- **Administrative Changes**
  - Syncing dataset and tool documentation is now more robust

### Bug Fix
- Fixed an issue where navigating to dataset downloads for a dataset with no files could cause a redirect loop

## 0.8.1 (May 28, 2014)

### Enhancement
- **General Changes**
  - Changed the file organization of variable images and graphs
    - The new file structure now includes the data dictionary version of the variable

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
  - Added tables of regular member registrations by country and state for reporting purposes

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
  - Site admins are notified by email when an admin approves or asks a user to resubmit a DAUA
  - Added stats overview for system admins to track signups, DAUA submissions, and file downloads
- **Dataset Changes**
  - Dataset owners are notified when users make new dataset file access requests
  - Variable popups are now hidden when the `Esc` key is pressed
  - Users are notified by email when a dataset editor approves their file access request
- **General Changes**
  - Updated email styling template
  - Minor wording changes on About page and Home page
  - Documentation pages for tools and datasets now include the filename as part of the title
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
  - Dataset editors can now approve user access to datasets based on DAUA criteria
  - Removed variable lists to clean up interface
    - Variables are now downloaded via the dataset CSV download from the files area
  - Datasets can now specify release dates to allow users to see when those datasets will have files available
    - Datasets are highlighted when they have data available for download
  - Dataset file downloads display steps the user needs to take to access the file download
- **Tool Changes**
  - Tools can be marked as private to allow editors to work on them while they are a work in progress
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
    - Users are notified when their DAUAs are approved or sent back for resubmission
    - Executed DAUAs can now be uploaded alongside the originally submitted DAUAs
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
- Signing in and signing out on the datasets files page now forwards back to the last folder location
  - This was disabled in previous versions so that file downloads wouldn't trigger after sign in or sign out
- Datasets header tabs now display `Variables` instead of `Collection` and `Search` has been removed
- `Variables` section, formerly the `Collection` now displays a note on why certain variables have gold borders
- Added more descriptive links for datasets and tools
- Reduced the size of the header bar on smaller screen sizes
- External links now have different styling from internal links
- Markdown no longer escapes numbers to their ASCII representation re-enabling ordered lists in Markdown
- Documentation code fences can now be prettified using `<!--?prettify?-->` immediately before the code fence
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
- Home page is now more dynamic and includes direct links to available documentation, data, and tools
- Covariate datasets can now be requested and downloaded if the user has been granted access to the dataset
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
    - Datasets can be documented using markdown or plain text across multiple pages
      - `:datasets_path:` and `:tools_path:` can now be referenced in documentation
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
    - Dataset files are indexed to improve viewing folders with 1,000 or more files
  - **Collection**
    - Users can search across multiple datasets that have an associated data dictionary
      - [Spout](https://github.com/sleepepi/spout) helps format and maintain JSON data dictionaries
      - An example data dictionary is the [We Care Data Dictionary](https://github.com/sleepepi/wecare-data-dictionary)
      - Variables with pre-computed charts now display the chart in the collection viewer
      - Users can create lists of variables on the collection viewer
      - Variable charts are loaded when the image is placed in the web browser viewport
- **Tool Changes**
  - Tools can be added and documented

## 0.0.0 (October 21, 2013)

- Initial prototype of the National Sleep Research Resource splash page
- Skeleton files to initialize Rails application with testing framework and continuous integration
- Added the We Care Dataset to prototype bulk file downloads
- Added Windows and Mac OS X/Linux instructions for installing GNU Wget
