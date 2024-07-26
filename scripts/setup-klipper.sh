#!/bin/bash
set -e
COL='\033[1;32m'
NC='\033[0m' # No Color
echo -e "${COL}Setting up klipper"

echo -e "${COL}\nPreparing venv...\n${NC}"
# Prepare venv for klipper
python3 -m venv ~/klipper-venv

echo -e "${COL}Downloading klipper\n${NC}"
curl -o klipper.zip -L https://github.com/Klipper3d/klipper/archive/refs/heads/master.zip

echo -e "${COL}Extracting klipper\n${NC}"
unzip klipper.zip
rm -rf klipper.zip
mv klipper-master /klipper
echo "# replace with your config" >> /root/printer.cfg

~/klipper-venv/bin/pip install -r /klipper/scripts/klippy-requirements.txt

mkdir -p /mnt/external/extensions/klipper
cat << EOF > /mnt/external/extensions/klipper/manifest.json
{
        "title": "Klipper plugin",
        "description": "(Requires OctoKlipper plugin)"
}
EOF

cat << EOF > /mnt/external/extensions/klipper/start.sh
#!/bin/sh
KLIPPER_ARGS="/klipper/klippy/klippy.py /root/printer.cfg -l /tmp/klippy.log -a /tmp/klippy_uds"
/root/klipper-venv/bin/python \$KLIPPER_ARGS &
EOF

cat << EOF > /mnt/external/extensions/klipper/kill.sh
#!/bin/sh
pkill -f 'klippy\.py'
EOF

chmod +x /mnt/external/extensions/klipper/start.sh
chmod +x /mnt/external/extensions/klipper/kill.sh
chmod 777 /mnt/external/extensions/klipper/start.sh
chmod 777 /mnt/external/extensions/klipper/kill.sh

cat << EOF
${COL}
Klipper installed!
Please place your own klipper config file at /root/printer.cfg
Please kill the app and restart it again to see it in extension settings${NC}
EOF
