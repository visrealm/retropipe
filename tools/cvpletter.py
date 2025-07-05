import re
import sys
import subprocess
import pathlib
import os

def extract_bytes_from_line(line):
    match = re.search(r'DATA\s+BYTE\s+(.*)', line, re.IGNORECASE)
    if not match:
        return []
    byte_strs = match.group(1).split(',')
    return [int(b.strip().lstrip('$'), 16) if b.strip().startswith('$') 
            else int(b.strip(), 16) if b.strip().lower().startswith('0x') 
            else int(b.strip()) for b in byte_strs]

def convert_cvbasic_to_bin(input_path, bin_path):
    with open(input_path, 'r') as infile:
        output_bytes = []
        for line in infile:
            line = line.strip()
            if not line or line.startswith("'"):
                continue
            output_bytes.extend(extract_bytes_from_line(line))
    with open(bin_path, 'wb') as outfile:
        outfile.write(bytearray(output_bytes))
    print(f"[✓] Extracted {len(output_bytes)} bytes to {bin_path}")

def run_pletter(input_bin, output_bin):
    print(f"[~] Running pletter.exe: {input_bin} → {output_bin}")
    script_dir = pathlib.Path(__file__).parent.resolve()
    pletter_path = script_dir / 'cvbasic' / 'pletter.exe'

    result = subprocess.run([str(pletter_path), input_bin, output_bin], capture_output=True, text=True)
    if result.returncode != 0:
        print("❌ Pletter compression failed:")
        print(result.stderr)
        sys.exit(1)
    print(f"[✓] Compressed output written to {output_bin}")

def write_bas_from_bin(bin_path, bas_path, label='pletterFont'):
    with open(bin_path, 'rb') as f:
        data = f.read()
    
    with open(bas_path, 'w') as out:
        out.write(f"{label}:\n")
        for i in range(0, len(data), 8):
            line = ', '.join(f"${b:02x}" for b in data[i:i+8])
            out.write(f"    DATA BYTE {line}\n")
    print(f"[✓] Generated {len(data)} bytes in {bas_path}")

def derive_filenames(input_bas):
    base = os.path.splitext(input_bas)[0]
    return (
        f"{base}.bin",           # intermediate raw binary
        f"{base}.pletter.bin",   # compressed binary
        f"{base}.pletter.bas"    # final CVBasic output
    )

def main():
    if len(sys.argv) != 2:
        print("Usage: python cvbasic_pletter_pack.py <input.bas>")
        sys.exit(1)

    input_bas = sys.argv[1]
    raw_bin, compressed_bin, output_bas = derive_filenames(input_bas)

    convert_cvbasic_to_bin(input_bas, raw_bin)
    run_pletter(raw_bin, compressed_bin)
    write_bas_from_bin(compressed_bin, output_bas)

if __name__ == '__main__':
    main()