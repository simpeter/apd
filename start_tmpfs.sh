#!/bin/bash

sudo mkdir -p /mnt/geo /mnt/profile /mnt/rate /mnt/recommendation /mnt/reservation /mnt/user

sudo mount -ttmpfs tmpfs /mnt/geo
sudo mount -ttmpfs tmpfs /mnt/profile
sudo mount -ttmpfs tmpfs /mnt/rate
sudo mount -ttmpfs tmpfs /mnt/recommendation
sudo mount -ttmpfs tmpfs /mnt/reservation
sudo mount -ttmpfs tmpfs /mnt/user
