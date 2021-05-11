#set -x
#!/bin/bash
if (( $# < 2 ))
then
  echo " Argument:  SID  & RCV_FILE Expected "
fi

ORACLE_SID=$1;
RCV_FILE=$2
export ORAENV_ASK=NO;

DB_NAME=`echo $ORACLE_SID|rev|cut -c 2-|rev`
. ~oracle/${DB_NAME}.env >/dev/null;
if [ $? -ne 0 ]
then
echo "Unable to Set environment for $ORACLE_SID"
exit 3
fi
rman  target / <<EOF
@${RCV_FILE}
EOF
