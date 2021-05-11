undef PDBname
alter pluggable database &&PDBname
close immediate instances
=all
/
alter pluggable database &&PDBname
open instances
=all
/