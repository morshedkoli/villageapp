const fs = require('fs');
const path = require('path');

const files = [
  'd:/villageapp/clientapp/lib/_swap.js',
  'd:/villageapp/clientapp/lib/screens_new.dart'
];

files.forEach(file => {
  try {
    if (fs.existsSync(file)) {
      fs.unlinkSync(file);
      console.log(`✓ Deleted ${path.basename(file)}`);
    } else {
      console.log(`- ${path.basename(file)} does not exist`);
    }
  } catch (error) {
    console.log(`✗ Error deleting ${path.basename(file)}: ${error.message}`);
  }
});
