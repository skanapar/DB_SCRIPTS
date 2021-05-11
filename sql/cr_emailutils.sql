PROMPT CREATE OR REPLACE PACKAGE xfierroe.emailutils

CREATE OR REPLACE PACKAGE xfierroe.EmailUtils as
   
   procedure SetSender(pSender in varchar2);
   function GetSender
      return varchar2;

   procedure SetRecipient(pRecipient in varchar2);
   function GetRecipient
      return varchar2;

   procedure SetCcRecipient(pCcRecipient in varchar2);
   function GetCcRecipient
      return varchar2;

   procedure SetMailHost(pMailHost in varchar2);
   function GetMailHost
      return varchar2;

   procedure SetSubject(pSubject in varchar2);
   function GetSubject
      return varchar2;


   procedure Send(pMessage in varchar2);

   procedure Send(pSender      in varchar2,
                  pRecipient   in varchar2,
                  pMailHost    in varchar2, 
                  pCcRecipient in varchar2 := null, 
                  pSubject     in varchar2 := null, 
                  pMessage     in varchar2 := null);
   
end EmailUtils;
/

PROMPT CREATE OR REPLACE PACKAGE BODY xfierroe.emailutils

CREATE OR REPLACE PACKAGE BODY xfierroe.EmailUtils as
   
  /**
   *
   * Private section
   *
   */
   vSender      varchar2(2000);
   vRecipient   varchar2(2000);
   vCcRecipient varchar2(2000);
   vMailHost    varchar2(2000);
   vSubject     varchar2(2000);

   
  
  /**
   *
   * Public section
   *
   */
   procedure SetSender(pSender in varchar2)
   is
   begin

      if pSender is not null
      then
         vSender := pSender;
      end if;

   end SetSender;

   function GetSender
      return varchar2
   is
   begin

      return vSender;
      
   end GetSender;

   procedure SetRecipient(pRecipient in varchar2)
   is
   begin
   
      if pRecipient is not null
      then
         vRecipient := pRecipient;
      end if;
   
   end SetRecipient;

   function GetRecipient
      return varchar2
   is
   begin
   
      return vRecipient;
      
   end GetRecipient;

   procedure SetCcRecipient(pCcRecipient in varchar2)
   is
   begin
   
      vCcRecipient := pCcRecipient;
     
   end SetCcRecipient;

   function GetCcRecipient
      return varchar2
   is
   begin
   
      return vCcRecipient;
   
   end GetCcRecipient;
   

   procedure SetMailHost(pMailHost in varchar2)
   is
   begin
   
      if pMailHost is not null
      then
         vMailHost := pMailHost;
      end if;
   
   end SetMailHost;
   

   function GetMailHost
      return varchar2
   is
   begin
   
      return vMailHost;
   
   end GetMailHost;

   procedure SetSubject(pSubject in varchar2)
   is
   begin
   
      vSubject := pSubject;
         
   end SetSubject;
   
   

   function GetSubject
      return varchar2
   is
   begin
   
      return vSubject;
   
   end GetSubject;


   procedure Send(pSender      in varchar2,
                  pRecipient   in varchar2,
                  pMailHost    in varchar2, 
                  pCcRecipient in varchar2 := null, 
                  pSubject     in varchar2 := null, 
                  pMessage     in varchar2 := null)
   is
   
      vConnection  utl_smtp.connection; 
      vMessage     varchar2(4000); 
     
   begin 
   
      vConnection := utl_smtp.open_connection(pMailhost, 25);
    
      utl_smtp.helo(vConnection, pMailHost); 
      utl_smtp.mail(vConnection, pSender); 
      utl_smtp.rcpt(vConnection, pRecipient);
       
      vMessage := 'Date: '    ||
                   to_char(sysdate, 'fmDy, DD Mon YYYY fxHH24:MI:SS') ||
                                                         utl_tcp.crlf || 
                  'From: '    || pSender              || utl_tcp.crlf || 
                  'Subject: ' || pSubject             || utl_tcp.crlf ||
                  'To: '      || pRecipient           || utl_tcp.crlf;
   
      if pCcRecipient is not null
      then
         utl_smtp.rcpt(vConnection, pCcRecipient); 
         vMessage := vMessage || 'Cc: '|| pCcRecipient || utl_tcp.crlf;
      end if;  
   
      vMessage := vMessage || '' || utl_tcp.crlf || pMessage; 
   
      if length(vMessage) > 2000
      then
         vMessage := substr(vMessage, 1, 2000); 
      end if;
   
      utl_smtp.data(vConnection, vMessage);
      utl_smtp.quit(vConnection);
      
      exception
         when others
         then
            null;
      
   end Send;
   
                  
   procedure Send(pMessage in varchar2)
   is
   begin
   
      Send(vSender,
           vRecipient,
           vMailHost, 
           vCcRecipient, 
           vSubject, 
           pMessage);   
   
   end Send;
   
end EmailUtils;
/

