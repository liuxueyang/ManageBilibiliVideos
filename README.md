# ManageBilibiliVideos
Manage imported downloaded videos from Bilibili Android client

## How to use

1. check the `entry.json` file in each directory to get the position of the video title.
This is an example how to get the title of bonobono:
```perl
my $index = $data->{'ep'}{'index'} . $data->{'ep'}{'index_title'};
```
Another example about how to get the title of TOUCH:
```perl
my $index = $data->{'title'};
```
2. Update the source code at line 43 according to the json file.

3. run the program:
```bash
perl ./touch.pl PATH_TO_DIRECTORY
```
`PATH_TO_DIRECTORY` is an absolute path to the directory using `adb pull` to import to computer. eg:
```bash
adb pull /storage/emulated/0/Android/data/tv.danmaku.bili/download/s_5615
```
In this case, PATH_TO_DIRECTORY is the absolute path to `s_5615`. Those renamed videos is placed to the directory where the script runs.

4. If there are multiple `.flv` files for a video. The script will merge them into one. This requires `ffmpeg`.