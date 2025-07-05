import re
import sys
import os
import subprocess
from pathlib import Path
from collections import OrderedDict

SCRIPT_DIR = Path(__file__).parent.resolve()
PLETTER_EXE = SCRIPT_DIR / "cvbasic" / "pletter.exe"

def extract_labels_and_data(bas_path):
    label = None
    labels = OrderedDict()
    data_accum = []

    with open(bas_path, 'r') as f:
        for line in f:
            stripped = line.strip()

            if not stripped or stripped.startswith("'"):
                continue

            # Label detection (e.g., labelName:)
            if re.match(r'^[a-zA-Z_][\w]*\s*:$', stripped):
                if label and data_accum:
                    labels[label] = data_accum
                label = stripped[:-1].strip()
                data_accum = []
                continue

            # DATA BYTE detection
            match = re.search(r'DATA\s+BYTE\s+(.*)', stripped, re.IGNORECASE)
            if match and label:
                bytes_str = match.group(1).split(',')
                for b in bytes_str:
                    b = b.strip()
                    if b.startswith('$'):
                        data_accum.append(int(b[1:], 16))
                    elif b.lower().startswith('0x'):
                        data_accum.append(int(b, 16))
                    else:
                        data_accum.append(int(b))
    
    if label and data_accum:
        labels[label] = data_accum

    return labels

def write_bin(filename, data):
    with open(filename, 'wb') as f:
        f.write(bytearray(data))
    print(f"[✓] Wrote {filename} ({len(data)} bytes)")

def run_pletter(input_bin, output_bin):
    result = subprocess.run([str(PLETTER_EXE), str(input_bin), str(output_bin)],
                            capture_output=True, text=True)
    if result.returncode != 0:
        raise RuntimeError(f"❌ Pletter compression failed for {input_bin}:\n{result.stderr}")
    print(f"[✓] Compressed {input_bin.name} → {output_bin.name}")

def write_pletter_bas(bas_path, data, label):
    with open(bas_path, 'w') as f:
        f.write(f"{label}:\n")
        for i in range(0, len(data), 8):
            line = ', '.join(f"${b:02x}" for b in data[i:i+8])
            f.write(f"    DATA BYTE {line}\n")
    print(f"[✓] Wrote {bas_path.name} ({len(data)} bytes)")

def generate_all(bas_input):
    base = Path(bas_input).stem
    base_dir = Path(bas_input).parent.resolve()
    labels_data = extract_labels_and_data(bas_input)

    master_includes = []

    for label, data in labels_data.items():
        bin_file = base_dir / f"{base}.{label}.bin"
        plet_bin = base_dir / f"{base}.{label}.pletter.bin"
        plet_bas = base_dir / f"{base}.{label}.pletter.bas"

        # Write raw bin
        write_bin(bin_file, data)

        # Run pletter.exe
        run_pletter(bin_file, plet_bin)

        # Read pletter.bin and write .bas
        with open(plet_bin, 'rb') as f:
            compressed = f.read()
        write_pletter_bas(plet_bas, compressed, label)

        # Include line for master file
        master_includes.append(f"{label}:\n#include \"{plet_bas.name}\"\n")

    master_file = base_dir / f"{base}.pletter_include.bas"
    with open(master_file, 'w') as f:
        f.writelines(master_includes)
    print(f"\n[✓] Final include file written: {master_file.name}")

def main():
    if len(sys.argv) != 2:
        print("Usage: python cvbasic_pletter_labels.py <input.bas>")
        sys.exit(1)

    if not PLETTER_EXE.exists():
        print(f"❌ Can't find pletter.exe at {PLETTER_EXE}")
        sys.exit(1)

    try:
        generate_all(sys.argv[1])
    except Exception as e:
        print(str(e))
        sys.exit(1)

if __name__ == '__main__':
    main()