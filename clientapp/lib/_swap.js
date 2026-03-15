const fs = require('fs');
const path = require('path');

const dir = 'd:\\villageapp\\clientapp\\lib';
const old_file = path.join(dir, 'screens.dart');
const new_file = path.join(dir, 'screens_new.dart');
const bak_file = path.join(dir, 'screens.dart.bak');

// Backup old file
fs.copyFileSync(old_file, bak_file);
console.log('Backed up screens.dart -> screens.dart.bak');

// Copy new over old
fs.copyFileSync(new_file, old_file);
console.log('Copied screens_new.dart -> screens.dart');

// Remove temp file
fs.unlinkSync(new_file);
console.log('Removed screens_new.dart');

console.log('Done!');
