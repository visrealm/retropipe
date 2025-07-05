## CVBasic source DATA files to be plettered

These will be compressed and converted to filename.pletter.bas in the source directory. The `build.bat` script will scan this directory for any .bas file, compress it (keeping the data separation with labels) and place the output in the `/src` directory before building.

This allows me to easily edit the source data and have the compressed data generated for each build

See `/tools/cvpletter.py` for the script that does the hard work