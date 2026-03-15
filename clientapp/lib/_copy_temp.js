const fs = require('fs');

try {
  fs.copyFileSync('d:/villageapp/clientapp/lib/screens_new.dart', 'd:/villageapp/clientapp/lib/screens.dart');
  console.log('Successfully copied screens_new.dart to screens.dart');
  process.exit(0);
} catch (err) {
  console.error('Error:', err.message);
  process.exit(1);
}
