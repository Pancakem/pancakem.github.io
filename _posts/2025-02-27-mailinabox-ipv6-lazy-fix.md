---
layout: post
title: "mailinabox ipv6 lazy fix"
date: 2025-02-27 10:30:00 +0300
categories: nginx server admin
---

I am running a `mailinabox` instance, it works perfectly except the admin and the
static website go down on every reboot. Why? IPv6 rears its ugly head in my nginx
configuration. I have disabled IPv6, permanently in grub since my operating system
does not load `/etc/sysctl.conf` at start. Too lazy to find out why so I go into what
I describe here.

First I tried disabling IPv6 using `systctl`, inside `/etc/systctl.conf` I added lines
```
net.ipv6.conf.all.disable_ipv6=1
net.ipv6.conf.default.disable_ipv6=1
net.ipv6.conf.lo.disable_ipv6=1
net.ipv6.conf.eth0.disable_ipv6=1
```
and rebooted the box.

On running `ip -6 addr show`, IPv6 was still up. Manually running `sudo sysctl -p` turns it
off. But at this point my `/etc/nginx/conf.d/local.conf` had been updated to include IPv6
configurations. I have not checked but I think mailinabox does this at boot, since before
reboot the box was running well without these configurations.

Next step was to permanently disable IPv6 in boot options.
I opened `/etc/default/grub`, found the line with `GRUB_CMDLINE_LINUX_DEFAULT`:
 ```
 GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"
 ```
edited the line to become
 ```
 GRUB_CMDLINE_LINUX_DEFAULT="ipv6.disable=1 quiet splash"
 ```
then updated grub.
```
sudo update-grub
```

After another reboot my websites are still down. But this time round IPv6 is disabled. Weird
but since I did not have the time to find the root cause of the problem and I knew removing the
IPv6 configuration and restarting nginx solved the problem. I wrote a bash script that checks
the status of nginx, if it is not running it tests the configuration and checks for the IPv6
pattern of configuration in the result string and removes all lines with IPv6 conf and restarts
nginx. Here it is.

```bash
#!/bin/bash
if ! systemctl is-active --quiet nginx; then
    echo "Nginx is not running. Testing configuration..."
    nginx_test_output=$(nginx -t 2>&1)

    if echo "$nginx_test_output" | grep -q '[::]:'; then
        echo "IPv6 configuration issue detected. Editing local.conf..."
        cp /etc/nginx/conf.d/local.conf /etc/nginx/conf.d/local/conf.bak
        sed -i '/\[::\]/d' /etc/nginx/conf.d/local.conf

        echo "local.conf has been modified. Restarting Nginx..."
        systemctl restart nginx
        if systemctl is-active --quiet nginx; then
            echo "Nginx has been successfully restarted."
        else
            echo "Failed to restart Nginx. Rolling back. Please check the configuration manually."
            # I alert myself
            cp /etc/nginx/conf.d/local.conf.bak /etc/nginx/conf.d/local/conf
        fi

    else
        echo "Not an IPv6 issue."
        # I alert myself
    fi
else
    echo "Nothing to do"
fi
```
