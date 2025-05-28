{ config, pkgs, ... }: {

  home.username = "ratul";
  home.homeDirectory = "/home/ratul";
  home.stateVersion = "24.05";

  programs.home-manager.enable = true;

  # Enable useful programs
  programs.bash.enable = true;
  programs.git.enable = true;
  programs.neovim.enable = true;

  programs.alacritty = {
    enable = true;
    settings = {
      general.import = [ pkgs.alacritty-theme.ayu_mirage ];

      font = {
        normal = {
          family = "JetBrainsMono Nerd Font";
        };
        size = 10.5;
      };

      window = {
        dimensions = {
          columns = 70;
          lines = 20;
        };
        opacity = 0.7;
        blur = true;
        decorations = "full";
        startup_mode = "Windowed";
      };
    };
  };

  home.packages = with pkgs; [
    neofetch
    kdePackages.qtstyleplugin-kvantum
    libsForQt5.qtstyleplugin-kvantum
    libsForQt5.qt5ct
    telegram-desktop
    whatsie
    vscode
    gcc
    gnumake
    cmake
    kde-rounded-corners
  ];

  home.sessionVariables = {
    QT_STYLE_OVERRIDE = "kvantum";
    QT_QPA_PLATFORMTHEME = "qt5ct";
  };

  # Bengali fontconfig override
  home.file.".config/fontconfig/conf.d/69-bengali-fonts.conf".text = ''
    <?xml version='1.0'?>
    <!DOCTYPE fontconfig SYSTEM 'fonts.dtd'>
    <fontconfig>
      <match>
        <test name="lang" compare="contains">
          <string>bn</string>
        </test>
        <edit name="family" mode="prepend" binding="strong">
          <string>Lohit Bengali</string>
        </edit>
      </match>
    </fontconfig>
  '';
}

