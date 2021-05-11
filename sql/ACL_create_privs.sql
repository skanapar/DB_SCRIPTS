-- Create ACL (11g) and add connect priv to SYSTEM

begin
DBMS_NETWORK_ACL_ADMIN.CREATE_ACL(
Acl => 'utlmailpkg.xml',
Description => 'Normal Access',
Principal => 'SYSTEM',
Is_Grant => True,
Privilege => 'connect',
Start_Date => Null,
End_Date => Null);
End;
/

-- Add privileges to resolve hosts to SYSTEM

begin
DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE(
acl => 'utlmailpkg.xml',
principal => 'SYSTEM',
is_grant => true,
privilege => 'resolve');
end;
/

--Assign the created ACL to the mail server IP and port

begin
dbms_network_acl_admin.assign_acl (
acl => 'utlmailpkg.xml',
host => '127.0.0.1',
lower_port => 25,
upper_port => NULL);
end;
/