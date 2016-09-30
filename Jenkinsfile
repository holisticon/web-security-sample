properties properties: [
        [$class: 'BuildDiscarderProperty', strategy: [$class: 'LogRotator', artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '30', numToKeepStr: '10']],
        [$class: 'GithubProjectProperty', displayName: '', projectUrlStr: 'https://github.com/holisticon/web-security-sample'],
]

node {
    env.JAVA_HOME = tool 'jdk-8-oracle'
    def mvnHome = tool 'Maven 3.3.1'
    env.PATH = "${env.JAVA_HOME}/bin:${mvnHome}/bin:${env.PATH}"

    stage('Checkout') {
        checkout scm
    }

    stage('Build') {
        sh "${mvnHome}/bin/mvn clean package"
    }

    stage('Unit-Tests') {
        sh "${mvnHome}/bin/mvn test -Dmaven.test.failure.ignore"

        step([
                $class     : 'JUnitResultArchiver',
                testResults: 'angular-spring-boot-webapp/target/surefire-reports/TEST*.xml'
        ])
    }

    stage('Integration-Tests') {
        node('docker') {
            env.JAVA_HOME = '/Library/Java/JavaVirtualMachines/jdk1.8.0_25.jdk/Contents/Home/'
              env.PATH = "${env.JAVA_HOME}/bin:/usr/local/bin/bin:${env.PATH}"
            sh "${mvnHome}/bin/mvn -Pdocker -Ddocker.host=http://127.0.0.1:2375  clean verify -Dmaven.test.failure.ignore"
        }
    }
    stage('Security Checks') {
        sh "${mvnHome}/bin/mvn -PsecurityCheck install"
        publishHTML(target: [
                reportDir            : 'angular-spring-boot-web-app/target',
                reportFiles          : 'dependency-check-report.html',
                reportName           : 'OWASP Dependency Check Report',
                keepAll              : true,
                alwaysLinkToLastBuild: true,
                allowMissing         : false
        ])
    }

    step([
            $class     : 'ArtifactArchiver',
            artifacts  : '**/target/*.jar',
            fingerprint: true
    ])
    step([
            $class     : 'JUnitResultArchiver',
            testResults: 'angular-spring-boot-webapp/target/failsafe-reports/TEST*.xml'
    ])
    publishHTML(target: [
            reportDir            : 'angular-spring-boot-webapp/target/site/serenity/',
            reportFiles          : 'index.html',
            reportName           : 'Serenity Test Report',
            keepAll              : true,
            alwaysLinkToLastBuild: true,
            allowMissing         : false
    ])

}
