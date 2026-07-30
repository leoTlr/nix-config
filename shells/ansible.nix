{ self, system, pkgs, ... }:
let
  customPython = (pkgs.python3.withPackages (ps: with ps; [
    # playbook deps
    cryptography # ansible-vault requirement
    configparser
    dnspython
    flask
    #flask_limiter
    # kubernetes-validate
    kubernetes
    netaddr
    #pyOpenSSL
    python-hpilo
    #PyVmomi
    requests
    #selinux
    #uwsgi
    werkzeug

    # own deps
    jmespath # json_query filter
  ]));
in
pkgs.mkShell {

  packages = with pkgs; [
    customPython
    (ansible_2_14.override {
      python3 = customPython;
    })
    (ansible-lint.override {
      python3 = customPython;
    })
    self.outputs.packages.${system}.invhosts
  ];

  shellHook = ''
    echo "🚀 Development environment loaded!"
    echo "📦 $(python --version)"
    echo "📦 $(ansible --version)"
    echo ""
  '';

}
