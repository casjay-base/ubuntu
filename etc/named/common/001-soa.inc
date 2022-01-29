;default soa records
$TTL 38400  ; 10 hours 40 minutes
@       IN SOA  dns dns-admin (
        20220128212001      ; serial
        10800               ; refresh (3 hours)
        3600                ; retry (1 hour)
        1209600             ; expire (2 weeks)
        38400               ; minimum (10 hours 40 minutes)
        )
