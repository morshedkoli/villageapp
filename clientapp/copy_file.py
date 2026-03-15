import shutil

# Copy the file
shutil.copy2(r'd:\villageapp\clientapp\lib\screens_new.dart', r'd:\villageapp\clientapp\lib\screens.dart')
print('Copied successfully')

# Verify
lines = open(r'd:\villageapp\clientapp\lib\screens.dart').readlines()
print(f'Total lines: {len(lines)}')
print(f'Line 29: {lines[28]}')
