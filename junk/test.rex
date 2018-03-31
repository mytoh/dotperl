use Rex;

desc 'test';
task 'df' => sub {
  say scalar run 'df -h';
};

task 'cshrc' => sub {
  say scalar run 'tail  ~/.cshrc';
};

task 'pecast' => sub {
  run '~/pecast.sh';
};

task 'kill_mono' => sub {
  run 'killall mono-sgen';
};


task 'restart_peca' => sub {
  do_task 'kill_mono';
  run 'mono ~/huone/ohjelmat/peercaststation/PeerCastStation.exe &';
};
