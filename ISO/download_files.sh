#!/bin/sh
[ -e virtio-win-0.1.185.iso ] || wget https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso
[ -e 17763.737.190906-2324.rs5_release_svc_refresh_SERVER_EVAL_x64FRE_en-us_1.iso ] || wget https://software-download.microsoft.com/download/pr/17763.737.190906-2324.rs5_release_svc_refresh_SERVER_EVAL_x64FRE_en-us_1.iso

7z x virtio-win-0.1.185.iso
find -name '*.pdb' -delete
