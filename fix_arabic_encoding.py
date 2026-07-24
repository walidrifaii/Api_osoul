# -*- coding: utf-8 -*-
"""Fix Arabic mojibake in osoul_backup_dbgate.sql (UTF-8 misread as CP1256)."""

from pathlib import Path
import sys

sys.stdout.reconfigure(encoding="utf-8", errors="replace")

src = Path(__file__).with_name("osoul_backup_dbgate.sql")
dst = Path(__file__).with_name("osoul_backup_dbgate_utf8_fixed.sql")

text = src.read_text(encoding="utf-8")


def fix_mojibake(s: str) -> str:
    """Reverse: UTF-8 bytes were decoded as Windows-1256, then saved as Unicode."""
    try:
        return s.encode("cp1256").decode("utf-8")
    except (UnicodeEncodeError, UnicodeDecodeError):
        out = []
        i = 0
        n = len(s)
        while i < n:
            fixed = None
            for j in range(min(n, i + 24), i, -1):
                chunk = s[i:j]
                try:
                    fixed = chunk.encode("cp1256").decode("utf-8")
                    out.append(fixed)
                    i = j
                    break
                except (UnicodeEncodeError, UnicodeDecodeError):
                    continue
            if fixed is None:
                out.append(s[i])
                i += 1
        return "".join(out)


fixed = fix_mojibake(text)

checks = [
    ("\u0644\u0644\u0627\u064a\u062c\u0627\u0631", "للايجار"),
    ("\u0644\u0644\u0628\u064a\u0639", "للبيع"),
    ("\u0641\u064a\u0644\u0627", "فيلا"),
    ("\u0638\u201e", "mojibake leftover"),
]
print("Checks:")
for arabic, label in checks:
    print(f"  {label}: {arabic in fixed}")

dst.write_text(fixed, encoding="utf-8", newline="\n")
print("Wrote:", dst.name)
print("Bytes:", src.stat().st_size, "->", dst.stat().st_size)
