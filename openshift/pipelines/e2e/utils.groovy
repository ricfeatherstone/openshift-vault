

def download(url, name, executable=false) {
    sh "curl -sSL -o ${url} ${name}"

    if(executable) {
        sh "chmod +x name"
    }
}
