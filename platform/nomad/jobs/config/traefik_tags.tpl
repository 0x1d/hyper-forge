[
"traefik.enable=true",
"traefik.http.routers.${router}.rule=Host(`${url}`)",
"traefik.http.routers.${router}.tls=true",
"traefik.http.routers.${router}.tls.certresolver=${cert_resolver}"
]