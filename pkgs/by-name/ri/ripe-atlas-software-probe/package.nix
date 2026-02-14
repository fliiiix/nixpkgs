{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  openssl,
  pkg-config,
  withUser ? "ripe-atlas",
  withGroup ? "ripe-atlas",
  withMeasurementUser ? "ripe-atlas-measurement",
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ripe-atlas-software-probe";
  version = "5120";

  src = fetchFromGitHub {
    owner = "ripe-ncc";
    repo = finalAttrs.pname;
    tag = finalAttrs.version;
    hash = "sha256-rjhLLeUj6US76/joRVBmYeqKsPVE5KzZGdE4eEilEKI";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [ openssl ];

  # env.NIX_CFLAGS_COMPILE = toString [
  #   "-Wno-error=format-security"
  # ];
  hardeningDisable = [ "format" ];

  configureFlags = [
    "--with-probe-type=generic"
    #"--enable-systemd"
    "--disable-systemd"
    "--disable-chown"
    "--disable-setcap-install"
    "--runstatedir=/run"
    "--sysconfdir=${placeholder "out"}/var/lib/atlas"
    "--with-user=${withUser}"
    "--with-group=${withGroup}"
    "--with-measurement-user=${withMeasurementUser}"
  ];

  preBuild = ''
    sed -i '/install-exec-local:/,/^$/d' Makefile
  '';

  meta = {
    description = "Software probes for the RIPE ATLAS project.";
    homepage = "https://github.com/RIPE-NCC/ripe-atlas-software-probe";
    changelog = "https://github.com/RIPE-NCC/ripe-atlas-software-probe/blob/v${finalAttrs.version}/CHANGES.rst";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ l33tname ];
  };
})
