# DownloadSendSafely

This program permits you to download all the files in a SendSafely package 
from the MacOs or Linux command line.  Browser not required.

There are a couple of instances where you may want to do this.

The first case, and I have not researched this in detail, but
it seems that the SendSafely browser window sometimes fails to create
the popup window so you can save the file into a
specific directory.  I think this occurs when the browser focus
is in another tab, and the SendSafely window is hidden. 
There does not seem to be a way to recover from this issue,
except for restarting the download.   :( 

In the second case, if you’re using an AWS Dump Truck instance,
you would need to run the browser, go to Zendesk or SendSafely,
enter your credentials and download it via the browser.  In my
experience, running the remote browser (proxied X session from
the AWS machine to your local Mac) is an error prone,
unreliable, painfully slow experience.

You can run this program on an AWS Dump Truck instance and
have it download from SendSafely blazing fast.  This really
matters when you’re trying to get a 20g or 30g heap dump onto
the AWS DumpTruck machine.

### How to use it.

Please see detailed instruction in the Customer Support Shared Google Drive.

Here is the summary: 
* Get API credentials from SendSafely
    * Log into https://streamsets.sendsafely.com
    * Click your user icon in the upport right.  
    * Click on "Edit Profile"
    * Click on API Keys on the left menu. 
    * Enter a description; click "Generate Key".
    * Save the key and secret (you never get to see the secret again).  
* Set them as environment variables in your .bashrc or .zshrc:
    * export SENDSAFELY_API_SECRET=blahblahblah
    * export SENDSAFELY_API_KEY=yadayadayada

Go to the ZD page which has the Sendsafely package link that you want to download - it'll be something like this:  
```https://streamsets.sendsafely.com/receive/?thread=713J-KDPU&packageCode=wECAuHBZb1K09ve0e0athUEiFJwcJbRabb8j0FmORDA#keyCode=acAJJUPq_Cg7oh9aLdMQkx1JfDIGDzUKJy96kEHofLM```
Copy this package link and verify that there are no embedded spaces. Note, this package link is the
link to all the files in the group.  For example, if there are three files listed on the SendSafely page when you click the link, all 3 files
will be downloaded. 

The files are copied into the current working directory, so it's usually a good idea
to create a new directory for the files and `cd` into that directory.
  
Start the program:
```java -jar downloadsendsafely-0.5-SNAPSHOT-jar-with-dependencies.jar```
you'll be prompted to paste in the package link to download.

### How to build
In the project's root directory: 
```
mvn clean package
```
This will leave an executable jar file in the target directory.

### How to commit your changes: 

Use the git "fork and push" workflow desctibed here: 
```
https://gist.github.com/Chaser324/ce0505fbed06b947d962
```
