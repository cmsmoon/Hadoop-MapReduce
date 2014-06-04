import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.*;
import org.apache.hadoop.mapreduce.*;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;

import java.io.IOException;
import java.util.*;

public class Reduce extends Reducer<Text, Text, Text, IntWritable> {
    private IntWritable users = new IntWritable(); // number of unique users

    @Override
        public void reduce(Text key, Iterable<Text> values, Context context) throws IOException, InterruptedException {
        HashSet<String> unique = new HashSet<String>();
        for (Text value : values) {
            unique.add(value.toString());
        }
        users.set(unique.size());
        context.write(key, users);
    }
}
// END OF REDUCE CLASS
