# freetz-bisect

#### Hardware used (needed/recommended)
- FTDI with support for 3.3V (LVTTL) to track the output of the Fritz!Box's serial console
- Some kind of switchable outlet (any way to power on/off the Fritz!Box, I used a WiFi switchable for simplicity) 
- Recommended but not needed: Separate Ethernet NIC, I used a cheap USB Ethernet NIC
- Recommended but not needed: USB hub, this makes wiring easier
- Ethernet cable

![image 1](https://pfichtner.github.io/freetz-bisect/IMG_20220109_124304362.jpg)
![image 2](https://pfichtner.github.io/freetz-bisect/IMG_20220109_124311409.jpg)
![video 1](https://pfichtner.github.io/freetz-bisect/VID_20220109_124042858.mp4)
![video 2](https://pfichtner.github.io/freetz-bisect/VID_20220109_125347238.mp4)

```
docker run \
--net=host \            # I guess easier to handle than NAT
--privileged \          # to access /dev/ttyUSBx
--rm -it \
--user 0 \              # to run apt install (missing tools for push_firmware
--entrypoint "" \       # ignore the container's entrypoint, if any
-v $PWD:/workspace      # not needed, here resists my git checkout which I do copy using "cp -aT /workspace /freetz" inside the container to have a freetz checkout
-v $PWD/dl:/freetz/dl \ # share download directory (not needed if you don't already have downloaded dependencies in the past)
IMAGE=pfichtner/freetz \
/bin/bash
```


### as root
```
apt update -y
apt install -y cpio iproute2 ncftp iputils-ping net-tools
apt install -y mosquitto-clients screen
ifconfig enx00e04c534458:0 192.168.178.100 up
```

```
su freetz
```

### as freetz
copy .config and bisect.sh to container (```docker cp <local file> <container-id>:/```)

```
umask 0022 ; make menuconfig # configure your needs
cp -ax tools /tmp/ # copy tools (push_firmware changed its syntax during the years, let's use the version from master/main since we use it with current syntax)

git bisect start
git bisect good <SHA of latest version that is known to be good>
git bisect bad <SHA of first version that is known to be bad>
git bisect run /bisect.sh 
```

### what's this all about?
- The needle in the hay stack: How to find the one faulty commit in 2K commits that broke my router's firmware (sometime in the last four years)?
- Bug komm raus, Du bist umzingelt :-D

### some numbers
- one faulty commit that made some devices unusable
- last known working commit four years ago
- nearly 2,000 commits in those four years
- possible every commit
- any commit could in principle have caused the error, none could be excluded
- exponentially helps: Thanks to binary search you can find the error within 11 tries in 2,000 revisions
- took just an hour to compile the 11 firmware revisions, upload and test them

