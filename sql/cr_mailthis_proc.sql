create or replace procedure mailthis
(sdr in varchar2,
rcpt in varchar2,
sbjt in varchar2 default null,
mssg in varchar2,
mhst in varchar2 default 'localhost')
is
        mail_conn utl_smtp.connection;
        crlf constant varchar(2) := chr(13)||chr(10);
        smtp_tcpip_port constant pls_integer := 25;
begin
        mail_conn := utl_smtp.open_connection(mhst, smtp_tcpip_port);
        utl_smtp.helo(mail_conn, mhst);
        utl_smtp.mail(mail_conn, sdr);
        utl_smtp.rcpt(mail_conn, rcpt);
        utl_smtp.data(mail_conn, mssg);
        utl_smtp.quit(mail_conn);
end;
/

