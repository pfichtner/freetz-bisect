# freetz-bisect

## Challenge
Find the commit that stopped my Router from working properly within 2,000 commits over the last four years. 

#### Hardware used (needed/recommended)
- FTDI with support for 3.3V (LVTTL) to track the output of the Fritz!Box's serial console (how to detect faulty/non faulty revisions? I could determine it loooking at the serial console output)
- Some kind of switchable outlet (any way to power on/off the Fritz!Box, I used a WiFi switchable for simplicity) 
- Recommended but not needed: Separate Ethernet NIC, I used a cheap USB Ethernet NIC
- Recommended but not needed: USB hub, this makes wiring easier
- Ethernet cable

Please not: You can also bisect manually. Then you have to upload the firmware built manually to the Fritz!Box and verify manually if this firmware does or doesn't work. If running manually there is no need for the FTDI nor a switchable outlet. 

![image 1](https://pfichtner.github.io/freetz-bisect/IMG_20220109_124304362.jpg)
FTDI (right, at the end of blue cable) and USB NIC (blue box, green CAT cable) connected to the Fritz!Box. The Fritz!Box can be switched on and off using the switchable outlet (front, white)

![image 2](https://pfichtner.github.io/freetz-bisect/IMG_20220109_124311409.jpg)


```
 docker run \
 --net=host \             # I guess easier to handle than NAT
 --privileged \           # to access /dev/ttyUSBx
 --rm -it \
 -v $PWD:/workspace       # not needed, here resists my git checkout which I do copy using "cp -aT /workspace /freetz" inside the container to have a freetz checkout
 -v $PWD/dl:/freetz/dl \  # share download directory (not needed if you don't already have downloaded dependencies in the past)
 pfichtner/freetz \       # my version of a freetz docker image
 /bin/bash
```

### as root
```
sudo -E bash # switch to root user
apt update -y
apt install -y mosquitto-clients screen
ifconfig enx00e04c534458:0 192.168.178.100 up
exit # switch back to unprivileged user
```

### as builduser (unprivileged user/not root)
copy .config and bisect.sh to container (```docker cp <local file> <container-id>:/```)

```
umask 0022 ; make menuconfig # configure your needs
cp -ax tools /tmp/ # copy tools (push_firmware changed its syntax during the years, let's use the version from master/main since we use it with current syntax)

git bisect start
git bisect good <SHA of latest version that is known to be good>
git bisect bad <SHA of first version that is known to be bad>
git bisect run /bisect.sh 
```
### Screencast
<a href="http://pfichtner.github.io/bisect-asciinema/"><img src="https://pfichtner.github.io/bisect-asciinema/asciinema-poster.png" /></a>

### what's this all about?
- The needle in the hay stack: How to find the one faulty commit in 2K commits that broke my router's firmware (sometime in the last four years)?
- Bug komm raus, Du bist umzingelt :-D

### some numbers
- one faulty commit that stopped some devices from working properly
- last known working commit four years ago
- nearly 2,000 commits in those four years
- any commit could possibly have caused the error, none could be excluded
- exponentially to the rescue: Thanks to binary search you can find the error within **11** tries in **2,000 revisions**
- took just an hour to build (compile) the 11 firmware revisions, upload and test them on the real hardware
