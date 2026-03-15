import re

path = r'd:\villageapp\clientapp\lib\screens.dart'
with open(path, 'rb') as f:
    content = f.read().decode('utf-8')

# === CHANGE A ===

# 1. Add Icon and SizedBox before Text(tr('Doulatpara'...
old = "              children: [\n"
# Find the specific one followed by Doulatpara
anchor = "children: [\n                Text(tr('Doulatpara'"
idx = content.find("children: [\n                Text(tr('Doulatpara'")
if idx == -1:
    raise Exception("Could not find children+Doulatpara anchor")
# Insert after "children: [\n"
insert_after = "children: [\n"
insert_pos = idx + len(insert_after)
insertion = "                  const Icon(Icons.location_city_rounded, color: Colors.white, size: 32),\n                  const SizedBox(height: 12),\n"
content = content[:insert_pos] + insertion + content[insert_pos:]

# 2. Change .textTheme.titleLarge) to .textTheme.titleLarge?.copyWith(color: Colors.white))
# Only the Doulatpara line
old2 = ".textTheme.titleLarge),\n                const SizedBox(height: 6),"
new2 = ".textTheme.titleLarge?.copyWith(color: Colors.white)),\n                const SizedBox(height: 4),"
content = content.replace(old2, new2, 1)

# 4. Wrap Text(tr('Quick access to key pages'...)) with style
# Find the line with 'Quick access to key pages'
pat = re.compile(r"( +)Text\(tr\('Quick access to key pages', '([^']*)'\)\),")
m = pat.search(content)
if not m:
    raise Exception("Could not find Quick access to key pages line")
indent = m.group(1)
bengali = m.group(2)
replacement = (
    f"{indent}Text(\n"
    f"{indent}  tr('Quick access to key pages', '{bengali}'),\n"
    f"{indent}  style: const TextStyle(color: Colors.white70, fontSize: 13),\n"
    f"{indent}),"
)
content = content[:m.start()] + replacement + content[m.end():]

# 5. Change const SizedBox(height: 8) after the closing of the header section
# This is the one right after the closing ),  ],  ),  ),  line ~54
# Find "const SizedBox(height: 8)," that comes after the header block
# Look for it after "Quick access"
qa_pos = content.find("Quick access to key pages")
sh8_search = content.find("const SizedBox(height: 8),", qa_pos)
if sh8_search == -1:
    raise Exception("Could not find SizedBox(height: 8) after Quick access")
content = content[:sh8_search] + "const SizedBox(height: 16)," + content[sh8_search + len("const SizedBox(height: 8),"):]

# 6. Add shape to each of the 4 ListTile widgets (Citizens, Leaderboard, Notifications, Profile)
for name in ['Citizens', 'Leaderboard', 'Notifications', 'Profile']:
    # Find: title: Text(tr('NAME',
    pat_lt = re.compile(
        rf"(title: Text\(tr\('{name}', '[^']*'\)\),)\n"
    )
    m_lt = pat_lt.search(content)
    if not m_lt:
        raise Exception(f"Could not find title line for {name}")
    # Get the indentation of the title line
    line_start = content.rfind('\n', 0, m_lt.start()) + 1
    title_indent = ''
    for ch in content[line_start:]:
        if ch == ' ':
            title_indent += ' '
        else:
            break
    shape_line = f"\n{title_indent}shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),"
    insert_at = m_lt.end() - 1  # before the \n
    content = content[:m_lt.end()] + shape_line + content[m_lt.end():]

# === CHANGE B ===

# 1. Change padding: _pagePadding(context), to padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
# Find in the _ensureLogin context (near 'Login Required')
lr_pos = content.find("Login Required")
if lr_pos == -1:
    raise Exception("Could not find Login Required")
pp_search = content.rfind("_pagePadding(context)", 0, lr_pos)
if pp_search == -1:
    raise Exception("Could not find _pagePadding(context) before Login Required")
old_padding = "padding: _pagePadding(context),"
new_padding = "padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),"
pp_line_start = content.rfind("padding:", 0, lr_pos)
pp_line_end = content.find(",", pp_line_start) + 1
content = content[:pp_line_start] + new_padding + content[pp_line_end:]

# 2. Wrap Text(tr('Please login with Email OTP...
pat_pl = re.compile(r"( +)Text\(tr\('Please login with Email OTP to donate or report a problem\.', '([^']*)'\)\),")
m_pl = pat_pl.search(content)
if not m_pl:
    raise Exception("Could not find Please login... line")
indent_pl = m_pl.group(1)
bengali_pl = m_pl.group(2)
replacement_pl = (
    f"{indent_pl}Text(\n"
    f"{indent_pl}  tr('Please login with Email OTP to donate or report a problem.', '{bengali_pl}'),\n"
    f"{indent_pl}  style: const TextStyle(color: Color(0xFF6B7280)),\n"
    f"{indent_pl}),"
)
content = content[:m_pl.start()] + replacement_pl + content[m_pl.end():]

# 3. Change const SizedBox(height: 12) before FilledButton to const SizedBox(height: 16)
# Find in context of _ensureLogin
fb_pos = content.find("FilledButton(", m_pl.start())
if fb_pos == -1:
    raise Exception("Could not find FilledButton after Please login")
sh12_search = content.rfind("const SizedBox(height: 12),", m_pl.start(), fb_pos)
if sh12_search == -1:
    raise Exception("Could not find SizedBox(height: 12) before FilledButton")
old_sh12 = "const SizedBox(height: 12),"
new_sh16 = "const SizedBox(height: 16),"
content = content[:sh12_search] + new_sh16 + content[sh12_search + len(old_sh12):]

with open(path, 'wb') as f:
    f.write(content.encode('utf-8'))

print("All changes applied successfully.")
