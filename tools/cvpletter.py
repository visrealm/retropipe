import re
import sys
import subprocess
from pathlib import Path
from tempfile import TemporaryDirectory

SCRIPT_DIR = Path(__file__).parent.resolve()
PLETTER_EXE = SCRIPT_DIR / 'cvbasic' / 'pletter.exe'

def extract_labels_and_data(bas_path):
    label = None
    labels = {}
    data_accum = []

    with open(bas_path, 'r') as f:
        for line in f:
            stripped = line.strip()
            if not stripped or stripped.startswith("'"):
                continue

            if re.match(r'^[a-zA-Z_][\w]*\s*:$', stripped):
                if label and data_accum:
                    labels[label] = data_accum
                label = stripped[:-1]
                data_accum = []
                continue

            code_only = stripped.split("'", 1)[0].strip()
            match = re.search(r'DATA\s+BYTE\s+(.*)', code_only, re.IGNORECASE)
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

def compress_data_via_pletter(data, tempdir, label):
    bin_path = tempdir / f"{label}.bin"
    plet_path = tempdir / f"{label}.pletter.bin"

    with open(bin_path, 'wb') as f:
        f.write(bytearray(data))

    result = subprocess.run([str(PLETTER_EXE), str(bin_path), str(plet_path)],
                            capture_output=True, text=True)
    if result.returncode != 0:
        raise RuntimeError(f"[✗] Pletter compression failed for {label}:\n{result.stderr}")

    with open(plet_path, 'rb') as f:
        return list(f.read())

def write_final_bas(bas_output, compressed_blocks):
    with open(bas_output, 'w') as f:
        for label, compressed in compressed_blocks.items():
            f.write(f"{label}Pletter:\n")
            for i in range(0, len(compressed), 8):
                group = compressed[i:i+8]
                line = ', '.join(f"${b:02x}" for b in group)
                f.write(f"    DATA BYTE {line}\n")
            f.write("\n")
    print(f"[✓] Final encoded output: {bas_output.name}")

def main():
    if len(sys.argv) != 2:
        print("Usage: python cvbasic_pletter_inline.py <input.bas>")
        sys.exit(1)

    input_bas = Path(sys.argv[1])
    if not input_bas.exists():
        print(f"[✗] File not found: {input_bas}")
        sys.exit(1)

    if not PLETTER_EXE.exists():
        print(f"[✗] Missing pletter.exe at: {PLETTER_EXE}")
        sys.exit(1)

    labels_data = extract_labels_and_data(input_bas)
    compressed_blocks = {}

    with TemporaryDirectory() as tmp:
        tempdir = Path(tmp)
        for label, data in labels_data.items():
            compressed_blocks[label] = compress_data_via_pletter(data, tempdir, label)

    output_bas = Path.cwd() / f"{input_bas.stem}.pletter.bas"
    write_final_bas(output_bas, compressed_blocks)

if __name__ == '__main__':
    main()