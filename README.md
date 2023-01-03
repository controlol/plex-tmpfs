[<img alt="GitHub Workflow Status" src="https://img.shields.io/github/actions/workflow/status/controlol/plex-tmpfs/docker-publish-tag.yml?logo=github" />](https://github.com/controlol/plex-tmpfs/actions/workflows/docker-publish-tag.yml)
[<img src="https://img.shields.io/docker/image-size/controlol/plex-tmpfs?logo=docker" alt="Docker Image Size (Latest By Date)"/>](https://hub.docker.com/r/controlol/plex-tmpfs)
[<img alt="Docker Pulls" src="https://img.shields.io/docker/pulls/controlol/plex-tmpfs" />](https://hub.docker.com/r/controlol/plex-tmpfs)
[<img alt="GitHub release (latest by date)" src="https://img.shields.io/github/v/release/controlol/plex-tmpfs?logo=plex" />](https://github.com/controlol/plex-tmpfs/releases)

# Plex tmpfs
A docker image based of binhex/arch-plex but with tmpfs

## Why was this image created
Ever thought to yourself: "Why is Plex so slow" while browsing your Plex library? Well I certainly did! The database chosen by Plex is unfortunately not intended for large datasets. Moving the database to RAM finally solved the problem of slow loading pages in Plex. After doing this for about a year now on [Unraid OS](https://unraid.net/product) which already has a easily accessable RAM disk by default. I thought it would be useful to implement this in a docker image so it is easy to replicate on other systems.

### How does the Plex database work
The [SQLite](https://www.sqlite.org/index.html) database used by Plex is a file like database where each transaction performed on the database is done by opening the file and reading the requested row. While a file is opened for a transaction it is not possible to perform another transaction. If this was possible it would corrupt your database. Moving the database to a SSD can significantly improves the speed of your database already *(I see this as a requirement for any database!)* but still is not ideal for the size of some databases.

## Usage
```sh
docker run -d \
  --name plex-tmpfs
  -p 32400:32400 \
  -v /path/to/config:/config \
  -v /path/to/media:/media \
  --mount type=tmpfs,destination=/plex-db \
  --mount type=tmpfs,destination=/transcode \
  -e PUID=1000
  -e PGID=1000
  -e UMASK=002
  -e TZ=Europe/Amsterdam
  -e DB_BACKUP_INTERVAL="15 */3 * * *"
  --restart unless-stopped
  controlol/plex-tmpfs
```

#### Environment
View the function of each environment variable at [hotio/plex](https://hotio.dev/containers/plex/). On top of that this image adds the `DB_BACKUP_INTERVAL` variable. This variable accepts a valid [cron expression](https://en.wikipedia.org/wiki/Cron) and determines how often a backup of the database is created and saved to persistent storage.

## How does this image achieve blazing fast database performance
The base of this image is based of [hotio/plex](https://hotio.dev/containers/plex/), a tiny image for plex. This image extends the functionality of the original image by cloning the original database (/config/Plugin Support/Databases) to `/config/backup-databases`. This is only done if /config/backup-databases does not exist or the directory is empty. Then the backup directory will be cloned to `/plex-db` (tmpfs is mounted here). After this has succeeded the **original database folder will be deleted**! For that reason I highly recommend that you create a backup should anything go wrong. The original database folder needs to be deleted so a symlink to the tmpfs directory can be created.

#### Backups
Of course, because the database is now located in RAM it is important to regularly backup the database to persistent storage. By default this is done the 15th minute of every third hour. The database will be cloned to `/config/backup-databases`. This schedule can be changed by setting the `DB_BACKUP_INTERVAL` environment variable.

I also advice you to make regular backups of the complete `/config` directory. This can be done using a tool like rsync or rsnapshot to make incremental backups.

## Recommendations
If you are using this image you are probably already transcodign to a RAMdisk. This is also possble in this image by mounting a tmpfs file system to `/transcode`. Usually a single transcode does not grow beyond 0.5GB and thus should not be a problem to be done in RAM. Doing this will save your SSD from a bunch of unnecessary/temporary writes. Make sure that you set *Transcoder cache directory* also to `/transcode` in your Plex settings.

##### Increase fs.inotify.max_user_watches
Plex watches all the files it knows for changes, like deletions and newly added subfolders or files. If you have a large library the limit of how many files can be watched will be exceeded quickly. The limit for how many files can be watched is a kernel setting and can be changed by updating the sysctl. Because the [host and container share the kernel](https://github.com/controlol/plex-tmpfs/issues/3) it is not possible to change this setting only in a docker container. Changing the value on the host is explained [here](https://gist.github.com/ntamvl/7c41acee650d376863fd940b99da836f).

## Notes
Beware that the Plex database can grow a lot after using it for a long time, this can use a lot of your RAM eventually. My personal database is 4GB, but I can imagine databases growing much larger than that. Before Plex starts the database will be copied to RAM. After the copy has completed the total size of the database will be printed after which the Plex server will start.

If you already have a Plex Server I highly recommend you to create a copy of your current Plex configuration files before using this image.
