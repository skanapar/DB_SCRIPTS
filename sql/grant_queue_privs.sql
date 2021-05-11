begin
 dbms_aqadm.grant_queue_privilege(
            privilege   => 'ALL',
            queue_name  => '<queue_name>',
            grantee     => '&SCHEMA_ALIAS._xxx_role',
            grant_option => false);
end;
/