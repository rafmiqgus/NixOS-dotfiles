{}:

{
  bigfile = { enabled = false; };
  dashboard = { 
    enabled = true;
    sections = [
      { section = "header"; }
      { section = "keys"; gap = 1; padding = 3;}
      { icon = " "; title = "Recent Files"; section = "recent_files"; indent = 2; padding = 2; }
      { icon = " "; title = "Projects"; section = "projects"; indent = 2; padding = 3; }
    ];
  };
  explorer = { enabled = false; };
  indent = { enabled = false; };
  input = { enabled = false; };
  notifier = {
    enabled = false;
    timeout = 3000;
  };
  picker = { enabled = false; };
  quickfile = { enabled = false; };
  scope = { enabled = false; };
  scroll = { enabled = false; };
  statuscolumn = { enabled = false; };
  words = { enabled = false; };
  styles = {
    notification = {
      # wo = { wrap = true; } -- Wrap notifications
    };
  };
}
