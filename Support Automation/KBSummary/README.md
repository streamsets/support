# KbSummary

The program gathers information about how many Kbs were sent to customers as Support
ticket updates over a certain time frame.

### Usage
The program accepts these command-line arguments:

```shell script
usage: KbSummary
 -e,--end <arg>      end date (recent) yyyy/MM/dd
 -s,--start <arg>    start date (oldest) yyyy/MM/dd
 -u,--update <arg>   update database true/false
```

* If the arguments are not on the command line, or something is incorrect,
it prints a 'usage' message and exits.
* Process all the tickets that moved to SOLVED state between those dates. 
* if 'update mode' is true, then we update the database for each KB that was referenced in a ticket comment.
* Provide the number of tickets processed, a count of total comments and number of KB links that were found.  

### Run It
To run this program you need to configure a properties file. 
This file should have a have the email of a valid Zendesk user and a Zendesk Token to permit access to the ZD API.
You can get this token by going to Zendesk, click the "gear" icon in the left hand side icon-bar.
Then create an API token, using your name in the title to help determine ownership of the token.

In addition you'll need to have the datbaae username, password and JDBC URL in the properties file. 

Set application properties file path in the KBSUMMARY_PROPERTIES environment variable.

Then run the program like this: 
```java -jar KBSummary-1.0-SNAPSHOT-jar-with-dependencies.jar```

The prorgam will generate trace for every 100 tickets processed and will generate this trace at the end:
```
tickets: 1649 comments 20390 kbs: 22
elapsed time 875
```

## How to Build It
This program requires a custom version of the Cloudbees Zendesk API.  The original repo is:
```https://github.com/cloudbees-oss/zendesk-java-client```
My custom repo is: 
```https://github.com/rcprcp/zendesk-java-client```

In my custom repo, I have added support for Zendesk Views which was/is missing from the Cloudbees original version.   

* Download the zendesk-java-client: ``` git clone https://github.com/rcprcp/zendesk-java-client```
* cd into the zendesk-java-client directory.
* Build: ```mvn clean install```

* download this repo `git clone (TBD)`
* cd into the directory
* Build: ```mvn clean package```
* the completed "fat jar" can be found in the target/ subdirectory.