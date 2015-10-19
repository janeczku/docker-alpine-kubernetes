#docker run -d --name bats-test --dns=209.244.0.4 --dns-search=10.0.0.1.xip.io alpine-kubernetes:3.2 1>&2
#docker exec bats-test apk-install bind-tools 1>&2

setup() {
  docker history "alpine-kubernetes:3.2" >/dev/null 2>&1
}

@test "canary: dig & nslookup are present in test image" {
  run docker exec bats-test which dig && which nslookup
  [ $status -eq 0 ]
}

@test "DNS resolver is accepting requests" {
  run docker exec bats-test nslookup -retry=0 -t=2 -q=txt -class=CHAOS version.bind 127.0.0.1
  [ $status -eq 0 ]
}

@test "DNS resolver is configured as default nameserver" {
  run docker exec bats-test dig +short +time=1 +tries=1 id.server chaos txt
  [ $status -eq 0 ]
  [ $(expr "$output" : ".*localhost.*") -ne 0 ]
}

@test "DNS resolver picked up nameserver from resolv.conf" {
  run docker logs bats-test
  [ $status -eq 0 ]
  [ $(expr "$output" : ".*209\.244\.0\.4\:53.*") -ne 0 ]
}

@test "DNS resolver picked up search domain from resolv.conf" {
  run docker logs bats-test
  [ $status -eq 0 ]
  [ $(expr "$output" : ".*10\.0\.0\.1\.xip\.io.*") -ne 0 ]
}

@test "forwarding is working correctly" {
  run docker exec bats-test dig +short 10.0.0.1.xip.io
  [ $status -eq 0 ]
  [ "$output" = "10.0.0.1" ]
}

@test "single-label queries are qualified with search domain" {
  run docker exec bats-test dig +short redis
  [ $status -eq 0 ]
  [ "${lines[1]}" = "10.0.0.1" ]
}

@test "multi-label queries are qualified with search domain" {
  run docker exec bats-test dig +short redis.1979.staging
  [ $status -eq 0 ]
  [ "${lines[1]}" = "10.0.0.1" ]
}

@test "apk-install script should be present" {
  run docker exec bats-test which apk-install
  [ $status -eq 0 ]
}
