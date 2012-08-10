To build the repository do the following:

1) ~[V8_DIR]> make dependencies <br/>
2) ~[V8_DIR]> ./BuildV8ForAndroid [Path to NDK] [Name of Output Folder : Optional]


Uppgrading V8

1) Do a pull request from the github repo<br/>
2) In the directory [v8]/src do a grep for INADDR_LOOPBACK and change any instances to INADDR_ANY<br/>
3) Move over the debugger hack into the latest version (until Narwal is removed)

