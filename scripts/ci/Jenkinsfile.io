properties(
    [
        buildDiscarder(
            logRotator(
                numToKeepStr: '10'
            )
        ),
        disableConcurrentBuilds()
    ]
)
// change node back to node ('') for recent version, legacy for old
node ('legacy') {
    stage ('Checkout') {
        if(env.BRANCH_NAME == 'acceptance') {
            git url: 'git@gitlab.devops.geointservices.io:dgs1sdt/fritz.git', branch: 'acceptance', credentialsId: '0059b60b-fe05-4857-acda-41ada14d0c52', poll: true
        } else if (env.BRANCH_NAME == 'master') {
            git url: 'git@gitlab.devops.geointservices.io:dgs1sdt/fritz.git', branch: 'master', credentialsId: '0059b60b-fe05-4857-acda-41ada14d0c52', poll: true
        }
    }

    stage ('Test & Build') {
        sh """
        docker pull dgs1sdt/fritz:test

        docker stop Fritz || true && docker rm Fritz || true

        docker run --name Fritz -v `pwd`:/app -itd dgs1sdt/fritz:test

        docker exec Fritz /bin/bash -c "/app/scripts/tests.sh"
        """
    }

    stage ('SonarQube') {
       def sonarXmx = '512m'
       def sonarHost = 'https://sonar.geointservices.io'
       def scannerHome = tool 'SonarQube Runner 2.8';
       withSonarQubeEnv('DevOps Sonar') {
           // update env var JOB_NAME to replace all non word chars to underscores
           def jobname = JOB_NAME.replaceAll(/[^a-zA-Z0-9\_]/, "_")
           def jobshortname = JOB_NAME.replaceAll(/^.*\//, "")
           withCredentials([[$class: 'StringBinding', credentialsId: 'd5ddf49e-60e6-4816-b668-406eddd250af', variable: 'SONAR_LOGIN']]) {
               sh "JOB_NAME=${jobname} && JOB_SHORT_NAME=${jobshortname} && set && ${scannerHome}/bin/sonar-scanner -Dsonar.host.url=${sonarHost} -Dsonar.login=${SONAR_LOGIN} -Dsonar.projectName=fritz -Dsonar.projectKey=narwhal:fritz"
           }
       }
    }

    stage ('Fortify') {
       sh '/opt/hp_fortify_sca/bin/sourceanalyzer -64 -verbose -Xms2G -Xmx10G -b ${BUILD_NUMBER} -clean'
       sh '/opt/hp_fortify_sca/bin/sourceanalyzer -64 -verbose -Xms2G -Xmx10G -b ${BUILD_NUMBER} "**/*" -exclude "client/node_modules/**/*" -exclude "client/build/**/*" -exclude ".mvn/**/*" -exclude "target/**/*" -exclude "src/main/resources/static/**/*" -exclude "acceptance/node_modules/**/*" -exclude "**/squashfs-root/**/*"'
       sh '/opt/hp_fortify_sca/bin/sourceanalyzer -64 -verbose -Xms2G -Xmx10G -b ${BUILD_NUMBER} -scan -f fortifyResults-${BUILD_NUMBER}.fpr'
    }

    stage ('ThreadFix') {
       withCredentials([string(credentialsId: '809f5fe7-c5a3-47b8-8dbf-69cc83e7d435', variable: 'THREADFIX_VARIABLE')]) {
       sh "/bin/curl -v --insecure -H 'Accept: application/json' -X POST --form file=@fortifyResults-${BUILD_NUMBER}.fpr\
           https://threadfix.devops.geointservices.io/rest/applications/241/upload?apiKey=${THREADFIX_VARIABLE}"
       }
    }

    if(env.BRANCH_NAME == 'acceptance') {
        stage ('Deploy NGA') {
            withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: '8e717287-708e-440f-8fa8-17497eac5efb', passwordVariable: 'PCFPass', usernameVariable: 'PCFUser']]) {
                withEnv(["CF_HOME=${pwd()}"]) {
                    sh "cf login -a api.system.dev.east.paas.geointservices.io -u $PCFUser -p $PCFPass -o DGS1SDT -s 'Fritz'"
                    sh "cf push -f ./manifest-acceptance.yml"
                }
            }
        }
        stage ('Deploy VI2E') {
            withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'ff9fca26-b34c-42e2-bad9-c3cfa5722489', passwordVariable: 'pass', usernameVariable: 'user']]) {
            withEnv(["CF_HOME=${pwd()}"]) {
             sh "cf login -a api.system.vi2e.io -u $user -p $pass -o Lab-1 -s 'Fritz' --skip-ssl-validation"
             sh "cf push -f ./manifest-acceptance.yml"
            }
          }
        }
    } else if(env.BRANCH_NAME == 'master') {
        stage ('Deploy NGA') {
            withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: '8e717287-708e-440f-8fa8-17497eac5efb', passwordVariable: 'PCFPass', usernameVariable: 'PCFUser']]) {
                withEnv(["CF_HOME=${pwd()}"]) {
                    sh "cf login -a api.system.dev.east.paas.geointservices.io -u $PCFUser -p $PCFPass -o DGS1SDT -s 'Fritz'"
                    sh "cf push -f ./manifest.yml"
                }
            }
        }
        stage ('Deploy VI2E') {
            withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'ff9fca26-b34c-42e2-bad9-c3cfa5722489', passwordVariable: 'pass', usernameVariable: 'user']]) {
                withEnv(["CF_HOME=${pwd()}"]) {
                    sh "cf login -a api.system.vi2e.io -u $user -p $pass -o Lab-1 -s 'Fritz' --skip-ssl-validation"
                    sh "cf push -f ./manifest.yml"
                }
            }
        }
    }
}