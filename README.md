# Plex tmpfs
A docker image based of binhex/arch-plex but with tmpfs

## Why was this image created
Ever thought to yourself: "Why is Plex so slow" while browsing movies or series on Plex? Well I certainly did! The database chosen by Plex is unfortunately not intended for large datasets. The SQLite database is a file like database where each transaction on the database is done by opening the file and reading the requested row. While the file is opened for a transaction it is not possible to do another transaction, if this were to be possible it would corrupt your database.

Moving the database to a SSD can significantly improve the speed of your database already (I see this as a requirement for any database!) but still was not ideal for the size of some databases. Moving the database to RAM finally solved the porblem of slow loading pages in Plex. After doing this for about a year now on [Unraid OS](https://unraid.net/product) which already had a RAM disk. I thought it would be useful to implement it in the docker image it self. 

## Usage
```sh
docker run -d \
  --name plex-tmpfs
  -p 32400:32400 \
  -v /path/to/config:/config \
  --mount type=tmpfs,destination=/plex-db \
  --mount type=tmpfs,destination=/config/transcode \
  -e PUID 1000
  -e PGID 1000
  -e UMASK 000
  -e TZ Europe/Amsterdam
  --restart unless-stopped
  controlol/plex-tmpfs
```

### What changed
The base of this image is based of [binhex/arch-plex](https://github.com/binhex/arch-plex), a tiny image for plex. Fortunately all the tools required to properly move the databases to RAM. So the size of the image has not increased by more than a couple KB. This image extends the functionality of the original image by cloning the original database (`/config/Plex Media Server/Plugin Support/Databases`) to `/config/backup-databases`. This is only done if `/config/backup-databases` does not exist or the directory is empty. Then the backup directory will be cloned to `/plex-db` (mount tmpfs here). After this has succeeded the original database folder will be **deleted**!! Therefor I highly recommend that you create a backup, and preferably craete backups periodically. The original folder needs to be deleted to be able to create a symlink that points to the tmpfs directory.

####
Of course, because the database is now located in RAM it is important to regularly backup the database. Currently this is done by cloning the database every night at 03:00. The database will be cloned to `/config/backup-databases`. In the near future it will be possible to add a schedule with a environment variable.

## Recommendations
I recommand to also specify the `TRANS_DIR` in the environment, if TRANSDIR is not set it will default to `/config/tmp`. Personally I have changed this to `/config/transcode` and mounted a tmpfs to the same location. Usually a single transcode does not grow beyond 0.5GB and thus should not be a problem to be done in RAM. Doing this will save your SSD from a bunch of unnecessary/temporary writes. 

## Notes
Beware that the Plex database can grow quite a lot over a longer period of time, this will eat up your RAM eventually. My personal database is 4GB, but I can imagine databases growing much larger than that.
