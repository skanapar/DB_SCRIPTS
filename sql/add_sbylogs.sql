alter database add standby logfile thread 1
group 17 ('+recoc1')  size 4G,
group 18 ('+recoc1')  size 4G,
group 19 ('+recoc1')  size 4G,
group 20 ('+recoc1')  size 4G,
group 21 ('+recoc1')  size 4G;

alter database add standby logfile thread 2
group 22 ('+recoc1')  size 4G,
group 23 ('+recoc1')  size 4G,
group 24 ('+recoc1')  size 4G,
group 25 ('+recoc1')  size 4G,
group 26 ('+recoc1')  size 4G;
