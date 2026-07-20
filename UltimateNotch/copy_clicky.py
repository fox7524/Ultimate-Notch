import os
import shutil

os.makedirs("/Users/fox/Documents/PROJECTS/Ultimate Notch/UltimateNotch/boringNotch/Assets.xcassets/clicky_icon.imageset", exist_ok=True)
shutil.copy("/Users/fox/Documents/PROJECTS/Ultimate Notch/main apps/clicky-main/leanring-buddy/Assets.xcassets/AppIcon.appiconset/1024-mac.png", "/Users/fox/Documents/PROJECTS/Ultimate Notch/UltimateNotch/boringNotch/Assets.xcassets/clicky_icon.imageset/clicky_icon.png")

with open("/Users/fox/Documents/PROJECTS/Ultimate Notch/UltimateNotch/boringNotch/Assets.xcassets/clicky_icon.imageset/Contents.json", "w") as f:
    f.write('{"images":[{"filename":"clicky_icon.png","idiom":"universal"}],"info":{"author":"xcode","version":1}}')
print("Done clicky icon")
