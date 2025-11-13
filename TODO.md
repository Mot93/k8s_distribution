# Work to be done
Traking issues and missing features

## TODO
- Documentation has to be expanded
- Rather than stop if there is a problem in downloading or uploading, it's more efficient to log what wasn't downloaded (and consequentely uploaded) and continue with the list
    - Add a feature to exlude element to upload or to target only specific element. This way it's not necessary to rewrite the list and the process can target specific items
- Add a flag to deactivate authentications
- Add a flag to only run authentications

## Issues
- Authentication is a command executed withouth checking what it's being run
    - Could add a promp before each authentication to ask if it's ok to launch the command
    - Add a flag that allow to ignore prompt 
