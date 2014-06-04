HADOOP = /opt/hadoop
JFLAGS = -d target
JAVAC = javac
CLASSPATH= ${HADOOP}/hadoop-core-1.1.1.jar:lib/commons-cli-1.2.jar
JAR = loganalysis.jar

all: loganalysis.jar

$(JAR):
        mkdir -p target
        $(JAVAC) -classpath $(CLASSPATH)  $(JFLAGS) src/*.java
        jar -cvf $(JAR) -C target/ .

clean:
        rm -rf target *.jar *.err *.out
