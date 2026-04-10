import groovy.json.JsonSlurperClassic

// ================= HELPER METHODS =================
@NonCPS
def extractHashFromResponse(String response) {
    def matcher = response =~ /"hash"\s*:\s*"([^"]+)"/
    return matcher.find() ? matcher.group(1) : ""
}

@NonCPS
def cleanJsonString(String rawOutput) {
    int firstBrace = rawOutput.indexOf('{')
    int lastBrace  = rawOutput.lastIndexOf('}')
    if (firstBrace == -1 || lastBrace == -1) return null
    return rawOutput.substring(firstBrace, lastBrace + 1)
}

// ================= PIPELINE =================
pipeline {
    agent any

    parameters {
        choice(
            name: 'BUILD_TYPE',
            choices: ['debug', 'release'],
            description: 'Pilih tipe build APK (Release direkomendasikan untuk audit)'
        )
    }

    environment {
        ANDROID_HOME     = "C:\\Users\\Nisrina\\AppData\\Local\\Android\\Sdk"
        ANDROID_SDK_ROOT = "${ANDROID_HOME}"
        FLUTTER_HOME     = "D:\\MobDev\\Flutter SDK\\flutter"
        JAVA_HOME        = "C:\\Program Files\\Java\\jdk-17"

        PATH = "${FLUTTER_HOME}\\bin;${JAVA_HOME}\\bin;${ANDROID_HOME}\\platform-tools;${ANDROID_HOME}\\emulator;${env.PATH}"

        AVD_NAME    = "Pixel_4_XL"
        APP_PACKAGE = "com.dhilla.newcity"

        MOBSF_URL   = "http://localhost:8000"
        MOBSF_TOKEN = "67f8dcdbaf63751750653685407053c3e1762a3394c5833de1d00379ca06c0fe"
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'master', url: 'https://github.com/nissrinayy/NewCity-Mobile-FE.git'
            }
        }

        stage('Prepare Workspace') {
            steps {
                bat 'if not exist apk-outputs mkdir apk-outputs'
            }
        }

        stage('Flutter Environment Check') {
            steps {
                bat """
                git config --global --add safe.directory "%WORKSPACE%"
                flutter config --jdk-dir "${env.JAVA_HOME}"
                flutter doctor -v
                """
            }
        }

        stage('Build APK') {
            steps {
                script {
                    bat """
                    flutter pub get
                    flutter build apk --${params.BUILD_TYPE} --no-split-per-abi
                    echo ========== APK OUTPUT LISTING ==========
                    dir build\\app\\outputs\\flutter-apk
                    echo ========== END LISTING ==========
                    """

                    def apkFiles = findFiles(glob: "build/app/outputs/flutter-apk/*.apk")
                    if (apkFiles.length == 0) {
                        error "No APK files found!"
                    }

                    env.APK_PATH = apkFiles[0].path
                    echo "APK stored: ${env.APK_PATH}"
                }
            }
        }

        stage('SAST - Static Analysis (MobSF)') {
            steps {
                script {
                    echo "Uploading APK to MobSF (SAST)..."

                    def uploadResponse = bat(
                        script: """
                        @curl -s ^
                        -H "Authorization: ${env.MOBSF_TOKEN}" ^
                        -F "file=@${env.APK_PATH}" ^
                        ${env.MOBSF_URL}/api/v1/upload
                        """,
                        returnStdout: true
                    ).trim()

                    def apkHash = extractHashFromResponse(uploadResponse)
                    if (!apkHash) error "MobSF upload failed"

                    env.APK_HASH = apkHash
                    echo "SAST Hash: ${apkHash}"

                    bat """
                    @curl -s -X POST ^
                    -H "Authorization: ${env.MOBSF_TOKEN}" ^
                    --data "hash=${apkHash}" ^
                    ${env.MOBSF_URL}/api/v1/scan
                    """

                    def rawReport = bat(
                        script: """
                        @curl -s -X POST ^
                        -H "Authorization: ${env.MOBSF_TOKEN}" ^
                        --data "hash=${apkHash}" ^
                        ${env.MOBSF_URL}/api/v1/report_json
                        """,
                        returnStdout: true
                    ).trim()

                    def json = cleanJsonString(rawReport)
                    if (json) {
                        writeFile file: 'sast_report.json', text: json
                        archiveArtifacts artifacts: 'sast_report.json'
                        echo "✅ SAST Report URL: ${env.MOBSF_URL}/static_analyzer/${apkHash}/"
                    }
                }
            }
        }

        stage('Start Emulator') {
            steps {
                bat """
                start /b "" "${env.ANDROID_HOME}\\emulator\\emulator.exe" ^
                -avd "${env.AVD_NAME}" ^
                -no-window -no-audio ^
                -gpu swiftshader_indirect -wipe-data
                """
                sleep 60
                bat "adb wait-for-device"
                bat "adb shell getprop sys.boot_completed"
            }
        }

        stage('Install APK') {
            steps {
                script {
                    def timestamp  = new Date().format("dd-MM-yyyy_HH-mm-ss")
                    def destPath   = "apk-outputs\\newcity-${params.BUILD_TYPE}-${timestamp}.apk"

                    bat "copy \"${env.APK_PATH}\" \"${destPath}\""

                    bat(script: "adb uninstall ${env.APP_PACKAGE}", returnStatus: true)
                    bat "adb install -r \"${destPath}\""
                }
            }
        }

        stage('DAST - Dynamic Analysis (MobSF)') {
            steps {
                script {
                    bat "adb shell input keyevent 82"
                    sleep 2

                    bat """
                    @curl -s -X POST ^
                    -H "Authorization: ${env.MOBSF_TOKEN}" ^
                    --data "hash=${env.APK_HASH}" ^
                    ${env.MOBSF_URL}/api/v1/dynamic/start_analysis
                    """

                    sleep 25

                    bat """
                    @curl -s -X POST ^
                    -H "Authorization: ${env.MOBSF_TOKEN}" ^
                    --data "hash=${env.APK_HASH}&default_hooks=api_monitor,ssl_pinning_bypass,root_bypass,debugger_check_bypass" ^
                    ${env.MOBSF_URL}/api/v1/frida/instrument
                    """

                    try {
                        bat "adb shell monkey -p ${env.APP_PACKAGE} --pct-syskeys 0 --throttle 1500 -v 200"
                    } catch (Exception e) {
                        echo "Monkey finished."
                    }

                    def tlsRaw = bat(
                        script: """
                        @curl -s -X POST ^
                        -H "Authorization: ${env.MOBSF_TOKEN}" ^
                        --data "hash=${env.APK_HASH}" ^
                        ${env.MOBSF_URL}/api/v1/android/tls_tests
                        """,
                        returnStdout: true
                    ).trim()

                    def tlsJson = cleanJsonString(tlsRaw)
                    if (tlsJson) {
                        writeFile file: 'tls_report.json', text: tlsJson
                    }

                    bat """
                    @curl -s -X POST ^
                    -H "Authorization: ${env.MOBSF_TOKEN}" ^
                    --data "hash=${env.APK_HASH}" ^
                    ${env.MOBSF_URL}/api/v1/dynamic/stop_analysis
                    """

                    def raw = bat(
                        script: """
                        @curl -s -X POST ^
                        -H "Authorization: ${env.MOBSF_TOKEN}" ^
                        --data "hash=${env.APK_HASH}" ^
                        ${env.MOBSF_URL}/api/v1/dynamic/report_json
                        """,
                        returnStdout: true
                    ).trim()

                    def json = cleanJsonString(raw)
                    if (json) {
                        writeFile file: 'dast_report.json', text: json
                        archiveArtifacts artifacts: 'dast_report.json, tls_report.json', allowEmptyArchive: true
                        echo "✅ DAST Report URL: ${env.MOBSF_URL}/dynamic_analyzer/${env.APK_HASH}/"
                    }
                }
            }
        }

        stage('Cleanup') {
            steps {
                bat 'taskkill /F /IM qemu-system-x86_64.exe /T || echo Emulator already stopped'
            }
        }
    }

    post {
        always {
            script {
                try {
                    emailext(
                        subject: "NewCity Mobile SAST & DAST Report - Build #${env.BUILD_NUMBER} - ${currentBuild.currentResult}",
                        body: """Halo tim!

Build pipeline NewCity Mobile selesai dengan status: ${currentBuild.currentResult}.

Laporan lengkap SAST dan DAST terlampir dalam format JSON.
- SAST: Static Analysis dari MobSF
- DAST: Dynamic Analysis dari MobSF

Terima kasih atas perhatiannya. Semangat audit APK-nya! 💪📱

Dikirim otomatis dari Jenkins.
""",
                        mimeType: 'text/plain',
                        to: '$DEFAULT_RECIPIENTS',
                        attachmentsPattern: 'sast_report.json,dast_report.json,tls_report.json',
                        attachLog: true,
                        compressLog: true,
                        recipientProviders: []
                    )
                    echo "Email dengan attachment reports dicoba kirim dari post block."
                } catch (Exception e) {
                    echo "Gagal kirim email: ${e.getMessage()}"
                }
            }
        }
    }
}