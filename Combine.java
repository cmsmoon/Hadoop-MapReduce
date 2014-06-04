import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.*;
import org.apache.hadoop.mapreduce.*;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;

import java.io.IOException;
import java.util.*;

public class Combine extends Reducer<Text, Text, Text, Text> {

    @Override
        public void reduce(Text key, Iterable<Text> values, Context context) throws IOException, InterruptedException {
        HashSet<String> uniques = new HashSet<String>();
        for (Text value : values) {
            if(uniques.add(value.toString()))
                context.write(key, value);
        }// end for
    }// end reduce
} // END OF COMBINE CLASS
