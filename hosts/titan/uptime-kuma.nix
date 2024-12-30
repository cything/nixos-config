{...}: {
  # data stored at /var/lib/uptime-kuma/ but does not expose
  # an option to change it
  services.uptime-kuma = {
    enable = true;
    settings.PORT = "3001";
  };
}
