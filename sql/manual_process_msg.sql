Declare
   context    raw(10);
   reginfo    sys.aq$_reg_info;
   descr      sys.aq$_descriptor;
   payload    varchar2(501);
   payloadl   number;
Begin
   descr:= sys.aq$_descriptor('<queue_name>'
                             ,NULL
                             ,NULL
                             ,NULL
                             ,NULL);
   <callback_name>(context
                  ,reginfo
                  ,descr
                  ,payload
                  ,payloadl);
End;
/