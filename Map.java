import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.*;
import org.apache.hadoop.mapreduce.*;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;

import java.io.IOException;
import java.util.regex.*;

// Modify this so Reduce can count unique users based on
// date field (key) and users identified by IP Address
public class Map extends Mapper<Object, Text, Text, Text> {
    private Text ip = new Text();
    private Text date = new Text();
    // using Java's Regular Expression
    private Pattern p = Pattern.compile("(\\d{2}[/][A-Z][a-z][a-z][/]\\d{4})");
    @Override
        public void map(Object key, Text value, Context context)
        throws IOException, InterruptedException {
        String[] entries = value.toString().split(" ");
        ip.set(entries[0]);
        for(int i = 0; i < entries.length; i++) {
            Matcher matcher = p.matcher(entries[i]);
            if(matcher.find()) {
                date.set(matcher.group()); // this needs to be just the day, month, and year
            }
        }
        context.write(date, ip);
    } // end of map function
} // END OF MAP CLASS
