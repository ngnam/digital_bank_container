ERROR:/workspaces/digital_bank_container/digital_bank_app/android/app/src/main/res/mipmap-mdpi/ic_laun
cher.png.bak: Resource and asset merger: The file name must end with .xml or .png

fix error when re build flutter build apk --flavor dev -t lib/main_dev.dart -v

I'll search the Android res folders for backup (*.bak) files to identify what to remove, then delete the offending .bak files so resource merger accepts the build. I'll run a quick find to list .bak files. Expected outcome: list of .bak files under android/app/src/main/res.


echo "Finding .bak files under android res:" && find android/app/src/main/res -type f -name "*.bak" -print
Auto approved by rules echo, find

I'll remove those .bak files from Android res directories, keeping backups elsewhere (tools/backup_icons/) in case you want them restored. I'll move them into tools/backup_icons/ instead of deleting.


mkdir -p tools/backup_icons && for f in $(find android/app/src/main/res -type f -name "*.bak"); do mv "$f" tools/backup_icons/ || true; echo Moved $f; done && echo done
I'll run the build command again to verify the error is resolved.