
dir('ca') {
    sh 'curl -sSL -o cfssl https://pkg.cfssl.org/R1.2/cfssl_linux-amd64'
    sh 'curl -sSL -o cfssljson https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64'
    sh 'chmod +x cfssl cfssljson'

    sh './cfssl gencert -initca ../cfssl/ca-csr.json | ./cfssljson -bare ca'

    sh '''./cfssl gencert \
      -ca=ca.pem \
      -ca-key=ca-key.pem \
      -config=../cfssl/ca-config.json \
      -profile=default \
      ../cfssl/consul-csr.json | ./cfssljson -bare consul
'''

    sh '''./cfssl gencert \
      -ca=ca.pem \
      -ca-key=ca-key.pem \
      -config=../cfssl/ca-config.json \
      -profile=default \
      ../cfssl/consul-client-csr.json | ./cfssljson -bare consul-client

'''

    sh 'ls -las'

}
