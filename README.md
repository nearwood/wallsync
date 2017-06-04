# wallsync
PowerShell script to sync desktop wallpaper to the logon/lock screen.

## Usage

**Windows 7 only**

The first time it is run it will need administrator priviledges to create the folder structure needed in the `%SystemRoot%\system32` folder (namely: `%SystemRoot%\system32\oobe\info\backgrounds`). It will then set the permissions of the `backgrounds` folder to allow user writes for future background changes without administrator access.

If you have your desktop background set to multiple images in rotation, you can then set the script to run every X minutes using Windows Scheduler to sync it more-or-less with the current desktop background.

That's it. That's all I needed this to do. I created it since I kept getting comments on my desktop background slideshow images so I figure I would show off some more by syncing them to the lock screen when I am away from my desk.
