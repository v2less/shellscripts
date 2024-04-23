# Java Preflight Analysis

Helper docker image for use in pipeline builds, based on Alpine and OpenJDK.

Tools:
 * Checkstyle
 * PMD
 * [TODO] SpotBugs
 * [TODO] OpenClover
 * [TODO] JaCoCo

## Usage generic

The docker image is setup to mount the local directory and set working directory in the way that tools like [Jenkins](https://jenkins.io/) will use ephemeral docker images during execution.

    docker run --rm -it -w /work -v $(pwd):/work freelxs/java-static-check <command> <command arguments>

This will spin up the image run your command in a new container and remove the container after execution to not leave.

 Tools are added to the docker container in the `/opt` directory with a helper wrapper shell script that should be copied to `/usr/local/bin`

## Usage in Jenkins Declaritive Pipeline

Show how these scans can be part of a Jenkinsfile.


    pipeline {
      // Requires docker label to be setup for where agent-docker
      // definitions should be running to use none below
      agent none
      stages {
        stage( 'Java preflight check - Checkstyle'){
          agent {
            docker { image 'freelxs/java-static-check:latest'}
          }
          steps {
            sh 'checkstyle -c /opt/rules/sun_checks.xml src/main/java/*'
          }
        }
        stage( 'Java preflight check - PMD'){
          agent {
            docker { image 'freelxs/java-static-check:latest'}
          }
          steps {
            sh 'pmd -d src/main/java -l java -f xml -rulesets /opt/rules/java-quickstart.xml'
          }
        }
      }
    }


## Usage Checkstyle

Checkstyle example, from within your source directory:

    $ docker run --rm -it -w /work -v $(pwd):/work freelxs/java-static-check:latest checkstyle -c /opt/rules/google_checks.xml -f xml -o checksytle-report.xml src/main/java/*

    Starting audit...
    [ERROR] /work/src/main/java/com/mycompany/app/App.java:1: Missing package-info.java file. [JavadocPackage]
    [ERROR] /work/src/main/java/com/mycompany/app/App.java:7: Line has trailing spaces. [RegexpSingleline]
    [ERROR] /work/src/main/java/com/mycompany/app/App.java:7:1: Utility classes should not have a public or default constructor. [HideUtilityClassConstructor]
    [ERROR] /work/src/main/java/com/mycompany/app/App.java:8:1: '{' at column 1 should be on the previous line. [LeftCurly]
    [ERROR] /work/src/main/java/com/mycompany/app/App.java:9:5: Missing a Javadoc comment. [MissingJavadocMethod]
    [ERROR] /work/src/main/java/com/mycompany/app/App.java:9:28: '(' is followed by whitespace. [ParenPad]
    [ERROR] /work/src/main/java/com/mycompany/app/App.java:9:30: Parameter args should be final. [FinalParameters]
    [ERROR] /work/src/main/java/com/mycompany/app/App.java:9:44: ')' is preceded with whitespace. [ParenPad]
    [ERROR] /work/src/main/java/com/mycompany/app/App.java:10:5: '{' at column 5 should be on the previous line. [LeftCurly]
    [ERROR] /work/src/main/java/com/mycompany/app/App.java:11:27: '(' is followed by whitespace. [ParenPad]
    [ERROR] /work/src/main/java/com/mycompany/app/App.java:11:44: ')' is preceded with whitespace. [ParenPad]
    Audit done.
    Checkstyle ends with 11 errors.

## Usage PMD

Using PMD from within your source directory.

    $ docker run --rm -it -w /work -v $(pwd):/work freelxs/java-static-check:latest pmd -d src/main/java -l java -f xml -r pmd-report.xml -rulesets /opt/rules/java-quickstart.xml
    WARNING: This analysis could be faster, please consider using Incremental Analysis: https://pmd.github.io/pmd-6.55.0/pmd_userdocs_incremental_analysis.html
    <?xml version="1.0" encoding="UTF-8"?>
    <pmd xmlns="http://pmd.sourceforge.net/report/2.0.0"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://pmd.sourceforge.net/report/2.0.0 http://pmd.sourceforge.net/report_2_0_0.xsd"
        version="6.15.0" timestamp="2019-06-12T13:31:08.740">
    <file name="/work/src/main/java/com/mycompany/app/App.java">
    <violation beginline="8" endline="13" begincolumn="1" endcolumn="1" rule="UseUtilityClass" ruleset="Design" package="com.mycompany.app" class="App" externalInfoUrl="https://pmd.github.io/pmd/pmd_rules_java_design.html#useutilityclass" priority="3">
    All methods are static.  Consider using a utility class instead. Alternatively, you could add a private constructor or make the class abstract to silence this warning.
    </violation>
    </file>
    </pmd>


## Development process

Including a helper Makefile to streamline the process.

    make build
    make shell

## Generating public version

Once an image is created docker hub will build latest based on the `master` branch and generate versions of the image based on tags. Using semantic versioning for tags in the form of `x.y.z`

## Reference

 * [Wikipedia - Static Analysis Java](https://en.wikipedia.org/wiki/List_of_tools_for_static_code_analysis#Java)
 * [wikipedia - Java code coverage tools](https://en.wikipedia.org/wiki/Java_code_coverage_tools)
 * [Checkstyle](http://checkstyle.sourceforge.net/)
 * [Checkstyle Releases](https://github.com/checkstyle/checkstyle/releases/)
 * [PMD](https://pmd.github.io/)
 * [SpotBugs](https://github.com/spotbugs/spotbugs)
 * [JaCoCo](https://www.jacoco.org/jacoco/)
