yachtsee.gb: yachtsee.o
	rgblink -o target/yachtsee.gb target/yachtsee.o
	rgbfix -v -p 0 --non-japanese --title YachtSee target/yachtsee.gb

yachtsee.o: tiles.2bpp tilemaps
	rgbasm -i lib -o target/yachtsee.o src/main.asm

tiles.2bpp:
	rgbgfx -f -o target/tiles.2bpp media/tiles.png

tilemaps:
	node fillTiles.js

clean:
	del target /s /q

build: yachtsee.gb