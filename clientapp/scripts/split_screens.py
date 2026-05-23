import os

def main():
    os.makedirs('lib/screens', exist_ok=True)
    
    with open('lib/screens.dart', 'r', encoding='utf-8') as f:
        lines = f.readlines()
        
    imports = "".join(lines[:17])
    
    slices = {
        'common.dart': (17, 1472),
        'root_shell.dart': (1472, 1644),
        'home_screen.dart': (1644, 2025),
        'village_fund_screen.dart': (2025, 2117),
        'donate_screen.dart': (2117, 2871),
        'projects_screen.dart': (2871, 3137),
        'problems_screen.dart': (3137, 3840),
        'citizens_page.dart': (3840, 4017),
        'leaderboard_page.dart': (4017, 4311),
        'profile_screen.dart': (4311, 4554),
        'auth_screens.dart': (4554, 5376),
        'notification_screen.dart': (5376, 5666),
        'ui_helpers.dart': (5666, 6125),
        'admin_panel_screen.dart': (6125, 6844),
        'more_helpers.dart': (6844, len(lines)),
    }
    
    for filename, (start, end) in slices.items():
        with open(f'lib/screens/{filename}', 'w', encoding='utf-8') as f:
            f.write(f"part of '../screens.dart';\n\n")
            f.write("".join(lines[start:end]))
            
    with open('lib/screens.dart', 'w', encoding='utf-8') as f:
        f.write(imports + '\n')
        for filename in slices.keys():
            f.write(f"part 'screens/{filename}';\n")
            
if __name__ == '__main__':
    main()
