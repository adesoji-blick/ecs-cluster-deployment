# Direction Application

This is a Java application written using Spring-boot framework that provides direction from point A, to point B. It uses Google Map API to work out steps based on mode of travel etc. 

### Requirements 

```
JDK/Java-8
mvn
```
### To build the app
```
git clone repo code
cd code
mvn clean package
cp target/*.jar /tmp/direction.jar
```

### To run the app
```
cp target/*.jar /tmp/direction.jar
loginname=myname loginpass=mypass api_key=my_google_api_key java -jar /tmp/direction.jar
```
