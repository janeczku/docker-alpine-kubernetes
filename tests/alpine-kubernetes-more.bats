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

@test "DNS resolver picked up both nameservers from resolv.conf" {
  skip "Need to fix this test case"
  run cat /var/log/s6-uncaught-logs/current
  [ $status -eq 0 ]
  [ $(expr "$output" : ".*8\.8\.4\.4\:53.*") -ne 0 ]
  [ $(expr "$output" : ".*8\.8\.8\.8\:53.*") -ne 0 ]
}

@test "DNS resolver picked up both search domains from resolv.conf" {
  skip "Need to fix this test case"
  run cat /var/log/s6-uncaught-logs/current
  [ $status -eq 0 ]
  [ $(expr "$output" : ".*[^.]google\.com.*") -ne 0 ]
  [ $(expr "$output" : ".*video\.google\.com.*") -ne 0 ]
}

@test "forwarding is working correctly" {
  run dig +short 46.128.179.1.dynamic.cablesurf.de
  [ $status -eq 0 ]
  [ "$output" = "46.128.179.1" ]
}

@test "single-label query is qualified" {
  run dig video-stats
  [ $status -eq 0 ]
  [ $(expr "$output" : ".*NOERROR.*") -ne 0 ]
}

@test "multi-label query is qualified" {
  run dig video-stats.video
  [ $status -eq 0 ]
  [ $(expr "$output" : ".*NOERROR.*") -ne 0 ]
}

@test "single-label query that can't be resolved returns NXDOMAIN" {
  run dig video-stats4
  [ $status -eq 0 ]
  [ $(expr "$output" : ".*NXDOMAIN.*") -ne 0 ]
}

@test "multi-label query that can't be resolved returns NXDOMAIN" {
  run dig video-stats4.video
  [ $status -eq 0 ]
  [ $(expr "$output" : ".*NXDOMAIN.*") -ne 0 ]
}

@test "very long valid domain is resolved" {
  run dig www.thelongestdomainnameintheworldandthensomeandthensomemoreandmore.com
  [ $status -eq 0 ]
  [ $(expr "$output" : ".*NOERROR.*") -ne 0 ]
}

@test "very long valid hostname is resolved" {
  run dig sdfsdfsdf.4.4ad5.asdasasd.asdds.www.10.0.0.1.xip.io
  [ $status -eq 0 ]
  [ $(expr "$output" : ".*NOERROR.*") -ne 0 ]
}
