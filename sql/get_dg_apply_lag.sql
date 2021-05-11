  select max( to_number(substr(value,2,2)) *86400 +
                   to_number(substr(value,5,2))*3600 +
                   to_number(substr(value,8,2))*60 +
                   to_number(substr(value,11,2))) apply_lag_seconds
               from v$dataguard_stats s
         where s.name in ( 'apply lag')
/

