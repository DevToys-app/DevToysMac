# Release Checklist

This is the procedure for doing a release.



1. Update the project version from Xcode's project pane

   Update both Version and Build (Sparkle seems to be referring to the build.)

2. Archive and Notarize app
   - With Distribute App > Developer ID

3. Create a tag for the release and push that tag.

4. Create a Github release page.

5. Create a zip file of the nolarized app on **local** (not the github page) and upload it to Asset.
   - The checksum of the zip file will be requested by appcast.

6. Generate appcast file with `generate_appcast` command.

7. Publish release on GitHub.

8. Update generated `appcast.xml` 's `<enclosure url="...">` to release asset URL.

9. Add new `appcast.xml` to git and push.

10. If needed, create `release-note.html` for Sparkle update.