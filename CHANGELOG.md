## 0.2.0

### Enhancements
- Use of Ruby 2.1.0 is now recommended
- **Gem Changes**
  - Updated to pg 0.17.1
  - Updated to jbuilder 2.0

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
