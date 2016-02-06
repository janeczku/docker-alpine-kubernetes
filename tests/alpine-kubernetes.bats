@test "canary: dig & nslookup are present in image" {
  run which dig && which nslookup
  [ $status -eq 0 ]
}

@test "DNS resolver is accepting requests" {
  run nslookup -retry=0 -t=2 -q=txt -class=CHAOS version.bind 127.0.0.1
  [ $status -eq 0 ]
}

@test "DNS resolver is configured as default nameserver" {
  run dig +short +time=1 +tries=1 id.server chaos txt
  [ $status -eq 0 ]
  [ $(expr "$output" : ".*localhost.*") -ne 0 ]
}

@test "DNS resolver picked up nameserver from resolv.conf" {
  skip "Need to fix this test case"
  run cat /var/log/s6-uncaught-logs/current
  [ $status -eq 0 ]
  [ $(expr "$output" : ".*8\.8\.4\.4\:53.*") -ne 0 ]
}

@test "DNS resolver picked up search domain from resolv.conf" {
  skip "Need to fix this test case"
  run cat /var/log/s6-uncaught-logs/current
  [ $status -eq 0 ]
  [ $(expr "$output" : ".*10\.0\.0\.1\.xip\.io.*") -ne 0 ]
}

@test "forwarding is working correctly" {
  run dig +short 46.128.179.1.dynamic.cablesurf.de
  [ $status -eq 0 ]
  [ "$output" = "46.128.179.1" ]
}

@test "single-label queries are qualified with search domain" {
  run dig +short redis
  [ $status -eq 0 ]
  [ "${lines[1]}" = "10.0.0.1" ]
}

@test "multi-label queries are qualified with search domain" {
  run dig +short redis.1979.staging
  [ $status -eq 0 ]
  [ "${lines[1]}" = "10.0.0.1" ]
}

@test "apk-install script should be present" {
  run which apk-install
  [ $status -eq 0 ]
}
