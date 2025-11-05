<!-- Banner -->
<pre align="center">
<code>
<pre align="center">
<code>
 ______   _                            ______  _             _   _  
(_____ \ | |              _           / _____)| |           | | | | 
 _____) )| |__    ___   _| |_   ___  ( (____  | |__   _____ | | | | 
|  ____/ |  _ \  / _ \ (_   _) / _ \  \____ \ |  _ \ | ___ || | | | 
| |      | | | || |_| |  | |_ | |_| | _____) )| | | || ____|| | | | 
|_|      |_| |_| \___/    \__) \___/ (______/ |_| |_||_____) \_) \_)
                                                                    
     > PhotoShell — your camera meets PowerShell ⚡
</code>
</pre>

</code>
</pre>

# 📸 PhotoShell

**A PowerShell module to organize, rename, and enhance your photos — right from your shell.**

PhotoShell helps photographers and enthusiasts automate their photo workflow: from importing and renaming files based on EXIF data to applying creative touches like framing and metadata editing.  
Designed for simplicity, automation, and flexibility — all in PowerShell.

---

## 🚀 Features

✅ Import photos from a folder, camera, or SD card 
✅ Rename files automatically using EXIF data (date, model, location, etc.)  
✅ **Planned features:**

- Create custom naming templates
- Manage metadata (EXIF, IPTC, XMP)
- Apply frames or borders  
- Batch resize and export  
- Add watermarks or captions  
- Integrate with Lightroom or cloud drives  

---

## 💻 Installation

```powershell
# Install from the PowerShell Gallery (coming soon)
Install-Module PhotoShell

# Or import manually
Import-Module .\PhotoShell.psd1
```

⚙️ Usage Examples

```powershell
# Import all photos from a folder

Import-Photos -Source "D:\DCIM" -Destination "C:\Pictures\"

## 🧠 Requirements

* PowerShell 7.0+

* Windows, macOS, or Linux

* exiftool

## 🛠️ Contributing

Contributions are welcome!
If you’d like to suggest features, fix bugs, or improve documentation:

1. Fork the repo

2. Create a feature branch

3. Submit a pull request

## 📄 License

This project is licensed under the MIT License — feel free to use and adapt it.