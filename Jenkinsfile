def precommit_container_image = "sloria/pre-commit"
def precommit_container_name = "pymapd-precommit-$BUILD_NUMBER"
def db_cuda_container_image = "omnisci/core-os-cuda"
def db_cpu_container_image = "omnisci/core-os-cpu"
def db_container_name = "pymapd-db-$BUILD_NUMBER"
def testscript_container_image = "rapidsai/rapidsai:0.15-cuda11.0-base-ubuntu18.04-py3.7"
def testscript_container_name = "pymapd-pytest-$BUILD_NUMBER"
def stage_succeeded
def git_commit

void setBuildStatus(String message, String state, String context, String commit_sha) {
  step([
      $class: "GitHubCommitStatusSetter",
      reposSource: [$class: "ManuallyEnteredRepositorySource", url: "https://github.com/omnisci/pyomnisci"],
      contextSource: [$class: "ManuallyEnteredCommitContextSource", context: context],
      commitShaSource: [$class: "ManuallyEnteredShaSource", sha: commit_sha],
      errorHandlers: [[$class: "ChangingBuildStatusErrorHandler", result: "UNSTABLE"]],
      statusResultSource: [ $class: "ConditionalStatusResultSource", results: [[$class: "AnyBuildResult", message: message, state: state]] ]
  ]);
}

pipeline {
    agent none
    options { skipDefaultCheckout() }
    stages {
        stage('Set pending status') {
            agent any
            steps {
                script {
                    if (env.GITHUB_BRANCH_NAME == 'master') {
                        script { git_commit = "$GITHUB_BRANCH_HEAD_SHA" }
                    } else {
                        script { git_commit = "$GITHUB_PR_HEAD_SHA" }
                    }
                }
                // Set pending status manually for all jobs before node is started
                setBuildStatus("Build queued", "PENDING", "Pre_commit_hook_check", git_commit);
                setBuildStatus("Build queued", "PENDING", "Pytest - [CPU] - Conda", git_commit);
                setBuildStatus("Build queued", "PENDING", "Pytest - [GPU] - Conda", git_commit);
                setBuildStatus("Build queued", "PENDING", "RBC tests - conda", git_commit);
            }
        }
        stage("Linter and Tests") {
            agent { label 'centos7-p4-x86_64 && tools-docker' }
            stages {
                stage('Checkout') {
                    steps {
                        checkout scm
                    }
                }
                stage('Pre_commit_hook_check') {
                    steps {
                        catchError(buildResult: 'FAILURE', stageResult: 'FAILURE') {
                            script { stage_succeeded = false }
                            setBuildStatus("Running tests", "PENDING", "$STAGE_NAME", git_commit);
                            sh """
                                docker pull $precommit_container_image
                                docker run \
                                  --rm \
                                  --entrypoint= \
                                  --name $precommit_container_name \
                                  -v $WORKSPACE:/apps \
                                  -w /apps \
                                  $precommit_container_image \
                                    pre-commit run --all-files
                                docker rm -f $precommit_container_name || true
                            """
                            script { stage_succeeded = true }
                        }
                    }
                    post {
                        always {
                            script {
                                if (stage_succeeded == true) {
                                    setBuildStatus("Build succeeded", "SUCCESS", "$STAGE_NAME", git_commit);
                                } else {
                                    sh """
                                        docker rm -f $precommit_container_name || true
                                    """
                                    setBuildStatus("Build failed", "FAILURE", "$STAGE_NAME", git_commit);
                                }
                            }
                        }
                    }
                }
                stage('Prepare Workspace') {
                    steps {
                        sh """
                            # Pull required test docker container images
                            docker pull $db_cuda_container_image
                            docker pull $db_cpu_container_image
                            docker pull $testscript_container_image
                        """
                    }
                }
                stage('Pytest - [CPU] - Conda') {
                    steps {
                        catchError(buildResult: 'FAILURE', stageResult: 'FAILURE') {
                            script { stage_succeeded = false }
                            setBuildStatus("Running tests", "PENDING", "$STAGE_NAME", git_commit);
                            sh """
                                $WORKSPACE/scripts/run_tests.sh \
                                    --db-image $db_cpu_container_image \
                                    --cpu-only
                            """
                            script { stage_succeeded = true }
                        }
                    }
                    post {
                        always {
                            script {
                                if (stage_succeeded == true) {
                                    setBuildStatus("Build succeeded", "SUCCESS", "$STAGE_NAME", git_commit);
                                } else {
                                    setBuildStatus("Build failed", "FAILURE", "$STAGE_NAME", git_commit);
                                }
                            }
                        }
                    }
                }
                stage('Pytest - [GPU] - Conda') {
                    steps {
                        catchError(buildResult: 'FAILURE', stageResult: 'FAILURE') {
                            script { stage_succeeded = false }
                            setBuildStatus("Running tests", "PENDING", "$STAGE_NAME", git_commit);
                            sh """
                                $WORKSPACE/scripts/run_tests.sh \
                                    --db-image $db_cuda_container_image \
                                    --gpu-only
                            """
                            script { stage_succeeded = true }
                        }
                    }
                    post {
                        always {
                            script {
                                if (stage_succeeded == true) {
                                    setBuildStatus("Build succeeded", "SUCCESS", "$STAGE_NAME", git_commit);
                                } else {
                                    setBuildStatus("Build failed", "FAILURE", "$STAGE_NAME", git_commit);
                                }
                            }
                        }
                    }
                }
                stage('RBC tests - conda') {
                    steps {
                        catchError(buildResult: 'FAILURE', stageResult: 'FAILURE') {
                            script { stage_succeeded = false }
                            setBuildStatus("Running tests", "PENDING", "$STAGE_NAME", git_commit);
                            sh """
                                $WORKSPACE/scripts/run_tests.sh \
                                    --db-image $db_cuda_container_image \
                                    --rbc-only
                            """
                            script { stage_succeeded = true }
                        }
                    }
                    post {
                        always {
                            script {
                                if (stage_succeeded == true) {
                                    setBuildStatus("Build succeeded", "SUCCESS", "$STAGE_NAME", git_commit);
                                } else {
                                    setBuildStatus("Build failed", "FAILURE", "$STAGE_NAME", git_commit);
                                }
                            }
                        }
                    }
                }
            }
            post {
                always {
                    sh """
                        docker rm -f $precommit_container_name || true
                        docker rm -f $testscript_container_name || true
                        docker rm -f $db_container_name || true
                        sudo chown -R jenkins-slave:jenkins-slave $WORKSPACE
                    """
                    cleanWs()
                }
            }
        }
    }
}
