perl script to delete the extra directories which may be found in $SDC_DATA/runInfo

These directories are sometimes left over when pipelines are deleted and some error
occurs which leaves these directories in place. 

This script gathers all the directories in the $SDC_DATA/pipelines directory and
the $SDC_DATA/runInfo directory, figures out which directories are in runInfo without a
corresponding entry in pipleines, and deletes the extra runInfo directories.

Also, the actual deleteing part is commented out, so you can try it and determine
if it meets your requirements. 
