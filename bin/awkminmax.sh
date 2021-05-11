#!/bin/awk -f 

BEGIN{
  # set the field separator to the "pipe" character
  FS=" "
  
}

{
  # check we have a 5 field input line:
  if( NF == 3 ) {


    if(array_min[$1,$2]>$3 || array_min[$1,$2]=="") {
      array_min[$1,$2]=$3 ;
    }
    
    
    if(array_max[$1,$2]<$3 || array_max[$1,$2]=="") {
      array_max[$1,$2]=$3 ;
    }
    
  }
}

END{
  
  for (i in array_min) {
    print i " " array_min[i] " " array_max[i]; 
  }  
}
