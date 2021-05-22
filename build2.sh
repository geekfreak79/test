#!/bin/bash

function tg_sendText() {
curl -s "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
-d "parse_mode=html" \
-d text="${1}" \
-d chat_id=$CHAT_ID \
-d "disable_web_page_preview=true"
}

function tg_sendFile() {
curl -F chat_id=$CHAT_ID -F document=@${1} -F parse_mode=markdown https://api.telegram.org/bot$BOT_TOKEN/sendDocument
}

cd /tmp/rom # Depends on where source got synced

tg_sendText "Cloning trees"
git clone https://github.com/aman25502/device_xiaomi_mojito -b bliss device/xiaomi/mojito
git clone https://github.com/PixelExperience-Devices/kernel_xiaomi_mojito --depth=1 kernel/xiaomi/mojito
git clone https://gitlab.pixelexperience.org/android/vendor-blobs/vendor_xiaomi_mojito --depth=1 vendor/xiaomi/mojito
git clone https://gitlab.pixelexperience.org/android/vendor-blobs/vendor_xiaomi_mojito-vendor --depth=1 vendor/xiaomi/mojito-vendor

tg_sendText "Setting up environment"
mkdir /tmp/ccache
# Normal build steps
. build/envsetup.sh
#lunch lineage_a10-userdebug
export CCACHE_DIR=/tmp/ccache
export CCACHE_EXEC=$(which ccache)
echo "export USE_CCACHE=1" >> ~/.bashrc
source ~/.bashrc
export USE_CCACHE=1
export WITH_GAPPS=false
export GAPPS_BUILD=false
export BLISS_BUILD_VARIANT=vanilla
ccache -M 20G # It took less than 6 GB for less than 2 hours in 2 builds for Samsung A10
ccache -o compression=true # Will save times and data to download and upload ccache, also negligible performance issue
ccache -z

tg_sendText "Started Collecting CCACHE....."

# Next 9 lines should be run first to collect ccache and then upload, after doning it 1 or 2 times, our ccache will help to build without these 8 lines.
#lunch bliss_mojito-userdebug
#make api-stubs-docs || echo no problem, we need ccache
#make system-api-stubs-docs || echo no problem we need ccache
#make test-api-stubs-docs || echo no problem, we need ccache
blissify mojito & # dont remove that '&'
sleep 45m
kill %1
ccache -s
#and dont use below codes for first 1 or 2 times, to get ccache uploaded,

#tg_sendText "Starting Compilation.."

# Compilation by parts if you get RAM issue but takes nore time!
#mka api-stubs-docs -j8
#mka system-api-stubs-docs -j8
#mka test-api-stubs-docs -j8
#mka bacon -j8 | tee build.txt

#blissify mojito | tee build.txt

(ccache -s && echo '' && free -h && echo '' && df -h && echo '' && ls -a out/target/product/mojito/) | tee final_monitor.txt
sleep 1s
tg_sendFile "final_monitor.txt"
sleep 2s
#tg_sendFile "build.txt"
