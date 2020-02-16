# Usage

Tested only on linux. Though it is Conda/Python stuff so prolly works on Windows as well.

I had a reason to filter out dropped/planned/held series when I transferred my list from MAL to AniList, which is why this script exists.

```
# Download/init MiniConda under ./conda. Activate the conda environment.
. init_conda
# Filter an exported MAL list in.xml -> out.xml.
# -p -w -c -d and -H correspond to 'Plan to Watch', 'Watching', 'Completed', 'Dropped' and 'On-Hold'.
# Leaving out the respective flags makes the corresponding entrie to be left out from the out file.
./mal_filter.py [-p] [-w] [-c] [-d] [-H] in.xml out.xml
```
