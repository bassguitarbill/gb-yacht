const { readFileSync, writeFileSync } = require('fs');

writeFileSync('lib/titleScreenTiles.bin', Buffer.from(Uint8Array.from(JSON.parse(readFileSync('tiles/titleScreenTiles.json').toString()).layers[0].data.map(x => x - 1))));