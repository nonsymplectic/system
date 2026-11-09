# ProtonVPN (OpenVPN) feature
#
# Wires the bundled ProtonVPN .ovpn profiles into the system:
#   - normalizes every profile at build time (credentials + DNS handling)
#   - `vpn-menu`   launcher-driven country picker (desktop entry)
#   - `vpn-up CC`  root wrapper that actually runs openvpn
#   - `vpn-down`   tears down any running tunnel
#
# Credentials come from agenix (`secrets/protonvpn_creds.age`), two lines:
#   <openvpn username>
#   <openvpn password>
# Those are the *OpenVPN/IKEv2* credentials from the Proton account page
#
# The vendor profiles in `options/vpn_configs` are kept free of account-bound
# and key material: the `<ca>` and `<tls-crypt>` blocks live in agenix
# (`secrets/protonvpn_ca.age`, `secrets/protonvpn_tls_crypt.age`) and are fed
# back to openvpn on the command line by `vpn-up`.
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.features.vpn;
  primaryUser = config.my.primaryUser;

  credsSecret = "/run/agenix/protonvpn_creds";
  caSecret = "/run/agenix/protonvpn_ca";
  tlsCryptSecret = "/run/agenix/protonvpn_tls_crypt";
  runtimeDir = "/run/vpn";

  countryNames = {
    ad = "Andorra";
    af = "Afghanistan";
    al = "Albania";
    am = "Armenia";
    ao = "Angola";
    ar = "Argentina";
    au = "Australia";
    az = "Azerbaijan";
    bd = "Bangladesh";
    be = "Belgium";
    bg = "Bulgaria";
    bh = "Bahrain";
    bo = "Bolivia";
    br = "Brazil";
    by = "Belarus";
    ca = "Canada";
    cd = "DR Congo";
    ch = "Switzerland";
    ci = "Côte d'Ivoire";
    cl = "Chile";
    cm = "Cameroon";
    cn = "China";
    cr = "Costa Rica";
    cz = "Czechia";
    de = "Germany";
    dk = "Denmark";
    do = "Dominican Republic";
    dz = "Algeria";
    ec = "Ecuador";
    ee = "Estonia";
    et = "Ethiopia";
    fi = "Finland";
    fr = "France";
    ga = "Gabon";
    ge = "Georgia";
    gh = "Ghana";
    gl = "Greenland";
    gn = "Guinea";
    gr = "Greece";
    gt = "Guatemala";
    hk = "Hong Kong";
    hn = "Honduras";
    ht = "Haiti";
    hu = "Hungary";
    id = "Indonesia";
    ie = "Ireland";
    "in" = "India";
    iq = "Iraq";
    is = "Iceland";
    it = "Italy";
    jm = "Jamaica";
    jo = "Jordan";
    jp = "Japan";
    ke = "Kenya";
    kg = "Kyrgyzstan";
    kh = "Cambodia";
    km = "Comoros";
    kr = "South Korea";
    kw = "Kuwait";
    kz = "Kazakhstan";
    lb = "Lebanon";
    li = "Liechtenstein";
    lk = "Sri Lanka";
    lt = "Lithuania";
    lu = "Luxembourg";
    ly = "Libya";
    ma = "Morocco";
    mc = "Monaco";
    md = "Moldova";
    me = "Montenegro";
    mn = "Mongolia";
    mr = "Mauritania";
    mt = "Malta";
    mu = "Mauritius";
    mx = "Mexico";
    my = "Malaysia";
    mz = "Mozambique";
    ni = "Nicaragua";
    nl = "Netherlands";
    np = "Nepal";
    om = "Oman";
    pa = "Panama";
    pe = "Peru";
    pg = "Papua New Guinea";
    ph = "Philippines";
    pk = "Pakistan";
    pl = "Poland";
    pr = "Puerto Rico";
    py = "Paraguay";
    qa = "Qatar";
    rw = "Rwanda";
    sn = "Senegal";
    sy = "Syria";
    td = "Chad";
    tg = "Togo";
    th = "Thailand";
    tj = "Tajikistan";
    tn = "Tunisia";
    tz = "Tanzania";
    ug = "Uganda";
    us = "United States";
    vn = "Vietnam";
    za = "South Africa";
    zw = "Zimbabwe";
  };

  # Country codes present in config directory
  codes = let
    isOvpn = name: type: type == "regular" && lib.hasSuffix ".ovpn" name;
    names = lib.attrNames (lib.filterAttrs isOvpn (builtins.readDir cfg.configDir));
  in
    lib.unique (lib.sort (a: b: a < b) (map (n: lib.head (lib.splitString "." n)) names));

  # normalization of the vendor profiles:
  #   - drop `auth-user-pass` (supplied on the command line from agenix)
  #   - drop the Debian-flavoured `up/down /etc/openvpn/update-resolv-conf`
  #     lines, which do not exist on NixOS (supplied on the command line too)
  vpnConfigs = pkgs.runCommand "protonvpn-configs" {} ''
    mkdir -p "$out"
    for f in ${cfg.configDir}/*.ovpn; do
      base="$(basename "$f")"
      cc="''${base%%.*}"
      # First profile wins if a country ships more than one file.
      [ -e "$out/$cc.ovpn" ] && continue
      ${pkgs.gnused}/bin/sed \
        -e '/^[[:space:]]*auth-user-pass/d' \
        -e '/update-resolv-conf/d' \
        "$f" > "$out/$cc.ovpn"
    done
  '';

  updateResolvConf = "${pkgs.update-resolv-conf}/libexec/openvpn/update-resolv-conf";

  vpn-up = pkgs.writeShellApplication {
    name = "vpn-up";
    runtimeInputs = [pkgs.openvpn pkgs.openresolv pkgs.iproute2 pkgs.coreutils pkgs.gnused];
    text = ''
      # Runs as root (via the sudo rule installed by this feature).
      cc="''${1:-}"
      case "$cc" in
        [a-z][a-z]) ;;
        *) echo "vpn-up: expected a two-letter country code, got '$cc'" >&2; exit 2 ;;
      esac

      conf="${vpnConfigs}/$cc.ovpn"
      if [ ! -f "$conf" ]; then
        echo "vpn-up: no profile for country code '$cc'" >&2
        exit 2
      fi

      # Credentials plus the key material the profiles no longer carry.
      for pair in \
        "${credsSecret}:secrets/protonvpn_creds.age" \
        "${caSecret}:secrets/protonvpn_ca.age" \
        "${tlsCryptSecret}:secrets/protonvpn_tls_crypt.age"
      do
        path="''${pair%%:*}"
        src="''${pair##*:}"
        if [ ! -r "$path" ]; then
          echo "vpn-up: $path is missing." >&2
          echo "        Populate it with: agenix -e $src" >&2
          exit 1
        fi
      done

      mkdir -p "${runtimeDir}"
      chmod 0700 "${runtimeDir}"
      creds="$(mktemp "${runtimeDir}/creds.XXXXXX")"
      chmod 0600 "$creds"
      # shellcheck disable=SC2064
      trap "rm -f '$creds'" EXIT HUP INT TERM

      username="$(sed -n 1p "${credsSecret}")"
      password="$(sed -n 2p "${credsSecret}")"
      ${lib.optionalString (cfg.netshieldSuffix != "") ''
        # Proton encodes NetShield/NAT flags as a username suffix; skip if the
        # stored username already carries one.
        case "$username" in
          *+*) ;;
          *) username="$username${cfg.netshieldSuffix}" ;;
        esac
      ''}
      printf '%s\n%s\n' "$username" "$password" > "$creds"

      echo "Connecting to $cc ..."
      set +e
      openvpn \
        --config "$conf" \
        --ca "${caSecret}" \
        --tls-crypt "${tlsCryptSecret}" \
        --auth-user-pass "$creds" \
        --auth-nocache \
        --script-security 2 \
        --up ${updateResolvConf} \
        --down ${updateResolvConf} \
        --down-pre
      rc=$?
      set -e

      if [ "$rc" -ne 0 ]; then
        echo
        echo "openvpn exited with status $rc. Press Enter to close."
        read -r _ || true
      fi
      exit "$rc"
    '';
  };

  vpn-down = pkgs.writeShellApplication {
    name = "vpn-down";
    runtimeInputs = [pkgs.procps];
    text = ''
      if pkill -TERM -x openvpn; then
        echo "Sent SIGTERM to openvpn."
      else
        echo "No openvpn process running."
      fi
    '';
  };

  # Each country line starts with the upper-cased code, so a selection maps
  # back to a code by taking the first whitespace-delimited field.
  randomLabel = "Random country";

  menuLines =
    [randomLabel]
    ++ map (cc: "${lib.toUpper cc}  ${cfg.flagPrefix}${countryNames.${cc} or cc}") codes;

  vpn-menu = pkgs.writeShellApplication {
    name = "vpn-menu";
    runtimeInputs = [pkgs.coreutils pkgs.gnugrep];
    text = ''
      entries=${lib.escapeShellArg (lib.concatStringsSep "\n" menuLines)}
      codes=${lib.escapeShellArg (lib.concatStringsSep "\n" codes)}

      choice="$(printf '%s\n' "$entries" | ${cfg.launcherCommand})" || exit 0
      [ -n "$choice" ] || exit 0

      case "$choice" in
        ${lib.escapeShellArg randomLabel})
          cc="$(printf '%s\n' "$codes" | shuf -n1)"
          ;;
        *)
          cc="$(printf '%s' "''${choice%% *}" | tr '[:upper:]' '[:lower:]')"
          ;;
      esac

      # Guard against anything the launcher echoed back that is not a profile.
      if ! printf '%s\n' "$codes" | grep -qxF "$cc"; then
        echo "vpn-menu: no profile for '$choice'" >&2
        exit 1
      fi

      exec ${lib.escapeShellArgs cfg.terminalCommand} sudo ${vpn-up}/bin/vpn-up "$cc"
    '';
  };
in {
  options.features.vpn = {
    enable = lib.mkEnableOption "ProtonVPN OpenVPN profiles with a launcher-driven picker";

    configDir = lib.mkOption {
      type = lib.types.path;
      default = ../../options/vpn_configs;
      description = ''
        Directory of vendor `.ovpn` profiles. Files are expected to be named
        `<country-code>.<anything>.ovpn`; the part before the first dot becomes
        the country code shown in the picker.
      '';
    };

    netshieldSuffix = lib.mkOption {
      type = lib.types.str;
      default = "+f1";
      example = "+f2";
      description = ''
        Suffix appended to the OpenVPN username to toggle Proton features
        (`+f1` anti-malware, `+f2` anti-malware and ads, `+nr` moderate NAT).
        Set to "" to send the username verbatim. Ignored when the stored
        username already contains a `+`.
      '';
    };

    launcherCommand = lib.mkOption {
      type = lib.types.str;
      default = "fuzzel --dmenu --prompt 'vpn> ' --lines 15";
      description = "dmenu-compatible launcher invocation used to pick a country.";
    };

    terminalCommand = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = ["foot" "--title" "openvpn" "--"];
      description = "Terminal command; the openvpn invocation is appended as trailing arguments.";
    };

    flagPrefix = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "String prepended to every country entry in the picker (e.g. an icon).";
    };

    passwordlessSudo = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Grant the `wheel` group NOPASSWD access to `vpn-up`/`vpn-down`. The
        wrappers accept only a two-letter country code resolved against a
        read-only store path, so this does not expose arbitrary openvpn
        configs (which could run scripts as root).
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [pkgs.openvpn pkgs.openresolv vpn-up vpn-down vpn-menu];

    # openresolv owns /etc/resolv.conf here; the up/down scripts push the
    # VPN-provided nameservers in under the tun interface and withdraw them on
    # disconnect.
    networking.resolvconf.enable = true;

    systemd.tmpfiles.rules = [
      "d ${runtimeDir} 0700 root root -"
    ];

    age.secrets.protonvpn_creds = {
      file = ../../secrets/protonvpn_creds.age;
      mode = "0400";
      owner = "root";
      group = "root";
    };

    age.secrets.protonvpn_ca = {
      file = ../../secrets/protonvpn_ca.age;
      mode = "0400";
      owner = "root";
      group = "root";
    };

    age.secrets.protonvpn_tls_crypt = {
      file = ../../secrets/protonvpn_tls_crypt.age;
      mode = "0400";
      owner = "root";
      group = "root";
    };

    security.sudo.extraRules = lib.mkIf cfg.passwordlessSudo [
      {
        groups = ["wheel"];
        commands = [
          {
            command = "${vpn-up}/bin/vpn-up";
            options = ["NOPASSWD"];
          }
          {
            command = "${vpn-down}/bin/vpn-down";
            options = ["NOPASSWD"];
          }
        ];
      }
    ];

    home-manager.users.${primaryUser} = {
      xdg.desktopEntries.vpn-menu = {
        name = "VPN";
        genericName = "ProtonVPN country picker";
        comment = "Pick a ProtonVPN exit country and connect in a terminal";
        exec = "${vpn-menu}/bin/vpn-menu";
        icon = "network-vpn";
        terminal = false;
        type = "Application";
        categories = ["Network" "Security"];
        startupNotify = false;
      };
    };
  };
}
