rmdir /s /q target
mkdir target

call generate-media.bat
node fillTiles.js

rgbasm -i lib -o target/main.o src/main.asm
rgblink -o target/hello-world.gb target/main.o

rgbfix -v -p 0 --non-japanese --title YachtSee target/hello-world.gb
