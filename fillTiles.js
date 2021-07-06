const { readFileSync, writeFileSync, readdirSync } = require('fs');

function convertTileFileToBin(name) { 
  writeFileSync(`target/${name}.bin`, Buffer.from(Uint8Array.from(JSON.parse(readFileSync(`tiles/${name}.json`).toString()).layers[0].data.map(x => x - 1))));
}

const tileFiles = readdirSync('tiles');
tileFiles.filter(fn => fn !== 'tiles.json').map(fn => fn.split('.')[0]).forEach(convertTileFileToBin);
