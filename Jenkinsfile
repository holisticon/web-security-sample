properties properties: [
        [$class: 'BuildDiscarderProperty', strategy: [$class: 'LogRotator', artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '30', numToKeepStr: '10']],
        [$class: 'GithubProjectProperty', displayName: '', projectUrlStr: 'https://github.com/holisticon/web-security-sample'],
]

node {
    env.JAVA_HOME = tool 'jdk-8-oracle'
    def mvnHome = tool 'Maven 3.3.1'
    env.PATH = "${env.JAVA_HOME}/bin:${mvnHome}/bin:${env.PATH}"

    try {
        stage('Checkout') {
            deleteDir()
            checkout scm
        }

        stage('Build') {
            sh "${mvnHome}/bin/mvn clean package"
        }

        stage('Unit-Tests') {
            try {
                sh "${mvnHome}/bin/mvn test -Dmaven.test.failure.ignore"
            } catch (err) {
                junit '**/target/surefire-reports/TEST-*.xml'
                throw err
            }
        }

        node('docker') {
            deleteDir()
            checkout scm

            stage('Integration-Tests') {
                env.JAVA_HOME = '/Library/Java/JavaVirtualMachines/jdk1.8.0_25.jdk/Contents/Home/'
                env.PATH = "${env.JAVA_HOME}/bin:/usr/local/bin/bin:${env.PATH}"
                try {
                    sh "mvn -Pdocker -Ddocker.host=http://127.0.0.1:2375  clean verify  -Dmaven.test.failure.ignore"
                } catch (err) {
                    publishHTML(target: [
                            reportDir            : 'angular-spring-boot-webapp/target/site/serenity/',
                            reportFiles          : 'index.html',
                            reportName           : 'Serenity Test Report',
                            keepAll              : true,
                            alwaysLinkToLastBuild: true,
                            allowMissing         : false
                    ])
                    junit '**/target/surefire-reports/TEST-*.xml'
                    throw err
                }

            }

            stage('Security Checks') {
                try {
                    sh "mvn -PsecurityCheck clean install"
                } catch (err) {
                    publishHTML(target: [
                            reportDir            : 'angular-spring-boot-webapp/target',
                            reportFiles          : 'dependency-check-report.html',
                            reportName           : 'OWASP Dependency Check Report',
                            keepAll              : true,
                            alwaysLinkToLastBuild: true,
                            allowMissing         : false
                    ])
                    throw err
                }
            }
        }

        step([
                $class     : 'ArtifactArchiver',
                artifacts  : '**/target/*.jar',
                fingerprint: true
        ])
    } catch (err) {
        rocketSend 'Error during pipeline'
        throw err
    }
}
