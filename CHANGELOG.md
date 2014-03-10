## 0.5.0

### Enhancements
- New sign ups can now be reviewed by system administrators
- Added Academic User Group page and added research summary for AUG Members
- Use of Ruby 2.1.1 is now recommended
- **Gem Changes**
  - Updated to contour 2.4.0

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
