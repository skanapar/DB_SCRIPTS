drop index p2kos_sidx
/
create index p2kos_sidx on p2kos(geom) 
indextype is mdsys.spatial_index 
parameters ('layer_gtype=point')
/
