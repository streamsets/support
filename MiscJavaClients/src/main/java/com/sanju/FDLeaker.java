package com.sanju;

import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.time.ZonedDateTime;
import java.util.LinkedList;
import java.util.Properties;
import java.io.File;

public class PropertiesFile {

    public static class Revision {

        final ZonedDateTime time = ZonedDateTime.now();
        final PropertiesFile file;

        Revision(PropertiesFile file) {
            this.file = file;
        }
    }

    private final InputStream stream;
    private Properties properties;

    PropertiesFile(InputStream stream) {
        this.stream = stream;
    }

    Properties getProperties() {
        if(this.properties == null) {
            properties = new Properties();
            try {
                properties.load(stream);
            } catch(IOException e) {
                e.printStackTrace();
            }
        }
        return properties;
    }

    @Override
    public boolean equals(Object o) {
        if(o instanceof PropertiesFile) {
            return ((PropertiesFile)o).getProperties().equals(getProperties());
        }
        return false;
    }

    public static void main(String[] args) throws IOException, InterruptedException {
        //URL url = new URL(args[0]);
        URL url=new File("/var/log/system.log").toURI().toURL();
        LinkedList<PropertiesFile.Revision> revisions = new LinkedList<>();
        // Loop indefinitely
        while(true) {
            // Load the file
            PropertiesFile pf = new PropertiesFile(url.openStream());
            // See if the file has changed
            if(revisions.isEmpty() || !revisions.getLast().file.equals(pf)) {
                // Store the new revision
                revisions.add(new PropertiesFile.Revision(pf));
                System.out.println(url.toString() + " has changed, total revisions: " + revisions.size());
            }
            Thread.sleep(1000);
        }
    }
}
